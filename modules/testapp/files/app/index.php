<?php

$messageString = 'This is a test message';

ob_start();
debug_print_backtrace();
$trace = ob_get_clean();

$message = array(
    'message' => $messageString,
    'CorrelationId' => uniqid(),
    'VariantId' => md5($messageString),
    'StackTrace' => $trace,
);

error_log(json_encode($message));