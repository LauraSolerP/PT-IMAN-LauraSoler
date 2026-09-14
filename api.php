<?php
declare(strict_types=1);

define('ENVIRONMENT', 'dev');

header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', '0');
error_reporting(E_ALL);

// Declaración de excepciones personalizadas para manejar diferentes tipos de errores.
class ValidationException extends Exception {}
class UnauthorizedException extends Exception {}
class UnauthenticatedException extends Exception {}
class ActionNotFoundException extends Exception {}

// Función para enviar respuestas JSON consistentes al cliente.
function sendResponse(bool $success, $data = null, string $message = '', int $httpCode = 200): void {
    http_response_code($httpCode);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data'    => $data,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Configuración de manejadores de errores y excepciones para capturar y responder adecuadamente a los errores.
set_error_handler(function ($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});

// Manejador de excepciones para capturar errores no manejados y enviar una respuesta JSON.
set_exception_handler(function (Throwable $e) {
    $httpCode = match (true) {
        $e instanceof ValidationException      => 400,
        $e instanceof UnauthenticatedException => 401,
        $e instanceof UnauthorizedException    => 403,
        $e instanceof ActionNotFoundException  => 404,
        default                                => 500,
    };

    $detail = $e->getMessage() . ' in file ' . $e->getFile() . ' (line ' . $e->getLine() . ')';

    $clientMessage = (ENVIRONMENT === 'dev') ? $detail : 'An internal error has occurred.';

    error_log($detail); 

    sendResponse(false, null, $clientMessage, $httpCode);
});

// Manejador de cierre del script para capturar errores fatales y enviar una respuesta JSON.
register_shutdown_function(function () {
    $error = error_get_last();
    if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
        $detail = $error['message'] . ' in file ' . $error['file'] . ' (line ' . $error['line'] . ')';
        $clientMessage = (ENVIRONMENT === 'dev') ? $detail : 'An internal error has occurred.';
        error_log($detail);

        if (!headers_sent()) {
            http_response_code(500);
            header('Content-Type: application/json; charset=utf-8');
        }
        echo json_encode(['success' => false, 'message' => $clientMessage, 'data' => null], JSON_UNESCAPED_UNICODE);
    }
});

// Función para sanitizar los datos de entrada, eliminando etiquetas HTML y caracteres especiales.
function sanitizeData($data) {
    if (is_array($data)) {
        return array_map('sanitizeData', $data);
    }
    if (is_string($data)) {
        return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
    }

    return $data;
}

// Función para validar los datos de entrada según un esquema definido.
function validateData(array $data, array $schema): void {
    foreach ($schema as $field => $rules) {
        $value = $data[$field] ?? null;

        if (!empty($rules['required']) && ($value === null || $value === '')) {
            throw new ValidationException("Field '$field' is required.");
        }

        if ($value === null || $value === '') {
            continue; 
        }

        switch ($rules['type'] ?? null) {
            case 'email':
                if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    throw new ValidationException("Field '$field' must be a valid email address.");
                }
                break;
            case 'integer':
                if (filter_var($value, FILTER_VALIDATE_INT) === false) {
                    throw new ValidationException("Field '$field' must be an integer.");
                }
                break;
            case 'text':
                if (isset($rules['max_length']) && mb_strlen((string)$value) > $rules['max_length']) {
                    throw new ValidationException("Field '$field' exceeds the maximum allowed length.");
                }
                break;
        }
    }
}

session_start();

$jsonBody = json_decode(file_get_contents('php://input'), true);
$requestData = is_array($jsonBody) ? $jsonBody : array_merge($_GET, $_POST);

$actionName = $requestData['action'] ?? null;

if (!$actionName || !is_string($actionName)) {
    sendResponse(false, null, 'No action was specified.', 400);
}

if (!preg_match('/^[a-zA-Z0-9_]+$/', $actionName)) {
    sendResponse(false, null, 'Action name format not allowed.', 403);
}

$cleanData = sanitizeData($requestData);

$actionFile = __DIR__ . '/actions/' . $actionName . '.php';

if (!file_exists($actionFile)) {
    throw new ActionNotFoundException("The requested action ('$actionName') does not exist.");
}

$actionDefinition = require $actionFile;

if (!is_array($actionDefinition) || !isset($actionDefinition['execute']) || !is_callable($actionDefinition['execute'])) {
    throw new Exception("Action file '$actionName' does not return a valid structure.");
}

// Verificacion de permisos y autenticación según la definición de la acción.
$isPublic = $actionDefinition['public'] ?? false;
$allowedRoles = $actionDefinition['roles'] ?? [];
$validationSchema = $actionDefinition['validate'] ?? [];

if (!$isPublic && empty($_SESSION['user_id'])) {
    throw new UnauthenticatedException('You must be logged in to perform this action.');
}

if (!$isPublic && !empty($allowedRoles)) {
    $userRole = $_SESSION['role'] ?? null;
    if (!in_array($userRole, $allowedRoles, true)) {
        throw new UnauthorizedException('You do not have permission to perform this action.');
    }
}

if (!empty($validationSchema)) {
    validateData($cleanData, $validationSchema);
}

$result = $actionDefinition['execute']($cleanData);

sendResponse(true, $result, 'Operation completed successfully.', 200);