<?php
/**
 * Test Suite for Application Center
 * 
 * Basic tests to validate core functionality
 */

require_once __DIR__ . '/../src/Env.php';
require_once __DIR__ . '/../src/Helpers.php';
require_once __DIR__ . '/../src/AstParser.php';
require_once __DIR__ . '/../src/AstSerializer.php';

// Test counter
$tests_passed = 0;
$tests_failed = 0;

function test($name, $callback) {
    global $tests_passed, $tests_failed;
    
    echo "\n🧪 Testing: $name\n";
    
    try {
        $callback();
        echo "✅ PASSED\n";
        $tests_passed++;
    } catch (Exception $e) {
        echo "❌ FAILED: " . $e->getMessage() . "\n";
        echo "   Stack trace: " . $e->getTraceAsString() . "\n";
        $tests_failed++;
    }
}

// Test 1: Environment loader
test("Environment loader", function() {
    $loaded = Env::load(__DIR__ . '/../.env.example');
    if (!$loaded) {
        // File might not exist in test environment
        echo "   ⚠️  .env.example not found (expected in test environment)\n";
        return;
    }
    
    if (!Env::has('FEATHERLESS_MODEL')) {
        throw new Exception("Failed to load environment variables");
    }
});

// Test 2: Helper functions
test("Helper functions", function() {
    $id = generateId();
    if (strlen($id) !== 32) {
        throw new Exception("Generated ID has incorrect length");
    }
    
    $sanitized = sanitize("<script>alert('xss')</script>");
    if (strpos($sanitized, '<script>') !== false) {
        throw new Exception("Sanitization failed");
    }
});

// Test 3: Parse example .astappcnt file
test("Parse .astappcnt file", function() {
    $exampleFile = __DIR__ . '/../data/apps/example.astappcnt';
    
    if (!file_exists($exampleFile)) {
        throw new Exception("Example file not found");
    }
    
    $parsed = AstParser::parseFile($exampleFile);
    
    if (!isset($parsed['app'])) {
        throw new Exception("Missing 'app' section");
    }
    
    if (!isset($parsed['style'])) {
        throw new Exception("Missing 'style' section");
    }
    
    if (!isset($parsed['questions']) || count($parsed['questions']) === 0) {
        throw new Exception("Missing or empty 'questions' section");
    }
    
    // Validate APP section
    if ($parsed['app']['id'] !== 'example_staff_app') {
        throw new Exception("Incorrect app ID");
    }
    
    if ($parsed['app']['name'] !== 'Staff Application') {
        throw new Exception("Incorrect app name");
    }
    
    // Validate STYLE section
    if ($parsed['style']['primary_color'] !== '#ff4b6e') {
        throw new Exception("Incorrect primary color");
    }
    
    // Validate questions
    $question = $parsed['questions'][0];
    if ($question['type'] !== 'multiple_choice') {
        throw new Exception("First question should be multiple_choice");
    }
    
    if (!isset($question['options']) || count($question['options']) === 0) {
        throw new Exception("Multiple choice question missing options");
    }
    
    echo "   ✓ Parsed APP section\n";
    echo "   ✓ Parsed STYLE section\n";
    echo "   ✓ Parsed " . count($parsed['questions']) . " questions\n";
});

// Test 4: Serialize and re-parse
test("Serialize and re-parse .astappcnt", function() {
    $testData = [
        'app' => [
            'id' => 'test_app',
            'name' => 'Test Application',
            'description' => 'Test description',
            'group_id' => 12345,
            'target_role' => 'groups/12345/roles/99999',
            'pass_score' => 75
        ],
        'style' => [
            'primary_color' => '#ff0000',
            'secondary_color' => '#00ff00',
            'background' => 'gradient:linear,#000,#fff',
            'font' => 'Arial',
            'button_shape' => 'square'
        ],
        'questions' => [
            [
                'id' => 'q1',
                'type' => 'multiple_choice',
                'text' => 'Test question?',
                'points' => 10,
                'options' => [
                    ['id' => 'a', 'text' => 'Option A', 'correct' => true],
                    ['id' => 'b', 'text' => 'Option B', 'correct' => false]
                ]
            ]
        ]
    ];
    
    // Serialize
    $tempFile = '/tmp/test_app.astappcnt';
    if (!AstSerializer::serializeToFile($testData, $tempFile)) {
        throw new Exception("Failed to serialize");
    }
    
    echo "   ✓ Serialized to file\n";
    
    // Parse back
    $parsed = AstParser::parseFile($tempFile);
    
    if ($parsed['app']['id'] !== 'test_app') {
        throw new Exception("Round-trip failed: incorrect app ID");
    }
    
    if ($parsed['app']['name'] !== 'Test Application') {
        throw new Exception("Round-trip failed: incorrect app name");
    }
    
    if ($parsed['questions'][0]['type'] !== 'multiple_choice') {
        throw new Exception("Round-trip failed: incorrect question type");
    }
    
    // Cleanup
    unlink($tempFile);
    
    echo "   ✓ Re-parsed successfully\n";
    echo "   ✓ Round-trip test passed\n";
});

// Test 5: JSON helper functions
test("JSON helper functions", function() {
    $testData = ['key' => 'value', 'number' => 42];
    $tempFile = '/tmp/test.json';
    
    if (!saveJson($tempFile, $testData)) {
        throw new Exception("Failed to save JSON");
    }
    
    $loaded = loadJson($tempFile);
    
    if (!$loaded || $loaded['key'] !== 'value' || $loaded['number'] !== 42) {
        throw new Exception("Failed to load JSON correctly");
    }
    
    unlink($tempFile);
});

// Test 6: Validation function
test("Validation function", function() {
    $data = ['name' => 'Test', 'email' => 'test@example.com'];
    
    $result = validateRequired($data, ['name', 'email']);
    if ($result !== true) {
        throw new Exception("Valid data failed validation");
    }
    
    $result = validateRequired($data, ['name', 'missing_field']);
    if ($result === true) {
        throw new Exception("Invalid data passed validation");
    }
});

// Test 7: AppController
test("AppController basic operations", function() {
    require_once __DIR__ . '/../src/AppController.php';
    
    $controller = new AppController();
    
    // Create app
    $result = $controller->createApp([
        'name' => 'Test App',
        'group_id' => 12345,
        'description' => 'Test description',
        'target_role' => 'groups/12345/roles/99999',
        'pass_score' => 80
    ]);
    
    if (!$result['success']) {
        throw new Exception("Failed to create app: " . ($result['error'] ?? 'unknown error'));
    }
    
    $appId = $result['id'];
    echo "   ✓ Created app with ID: $appId\n";
    
    // Load app
    $loadResult = $controller->loadApp($appId);
    
    if (!$loadResult['success']) {
        throw new Exception("Failed to load app: " . ($loadResult['error'] ?? 'unknown error'));
    }
    
    if ($loadResult['data']['app']['name'] !== 'Test App') {
        throw new Exception("Loaded app has incorrect name");
    }
    
    echo "   ✓ Loaded app successfully\n";
    
    // List apps
    $listResult = $controller->listApps();
    
    if (!$listResult['success']) {
        throw new Exception("Failed to list apps");
    }
    
    echo "   ✓ Found " . count($listResult['apps']) . " app(s)\n";
    
    // Cleanup
    $controller->deleteApp($appId);
});

// Print summary
echo "\n" . str_repeat("=", 60) . "\n";
echo "📊 TEST SUMMARY\n";
echo str_repeat("=", 60) . "\n";
echo "✅ Passed: $tests_passed\n";
echo "❌ Failed: $tests_failed\n";
echo "Total: " . ($tests_passed + $tests_failed) . "\n";
echo str_repeat("=", 60) . "\n";

if ($tests_failed > 0) {
    exit(1);
} else {
    echo "\n🎉 All tests passed!\n\n";
    exit(0);
}
