<?php
/**
 * Environment Configuration Loader
 * 
 * Loads environment variables from .env file into $_ENV
 */
class Env {
    private static $loaded = false;
    
    /**
     * Load environment variables from .env file
     * 
     * @param string $path Path to .env file
     * @return bool Success status
     */
    public static function load($path = null) {
        if (self::$loaded) {
            return true;
        }
        
        // Default path
        if ($path === null) {
            $path = __DIR__ . '/../.env';
        }
        
        if (!file_exists($path)) {
            return false;
        }
        
        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        
        foreach ($lines as $line) {
            // Skip comments
            if (strpos(trim($line), '#') === 0) {
                continue;
            }
            
            // Parse KEY=VALUE
            if (strpos($line, '=') !== false) {
                list($key, $value) = explode('=', $line, 2);
                $key = trim($key);
                $value = trim($value);
                
                // Remove quotes if present
                if (preg_match('/^(["\'])(.*)\\1$/', $value, $matches)) {
                    $value = $matches[2];
                }
                
                $_ENV[$key] = $value;
                putenv("$key=$value");
            }
        }
        
        self::$loaded = true;
        return true;
    }
    
    /**
     * Get an environment variable
     * 
     * @param string $key Variable name
     * @param mixed $default Default value if not found
     * @return mixed Variable value or default
     */
    public static function get($key, $default = null) {
        return $_ENV[$key] ?? getenv($key) ?: $default;
    }
    
    /**
     * Check if an environment variable exists
     * 
     * @param string $key Variable name
     * @return bool
     */
    public static function has($key) {
        return isset($_ENV[$key]) || getenv($key) !== false;
    }
}
