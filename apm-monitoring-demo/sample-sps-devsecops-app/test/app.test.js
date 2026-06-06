const { execSync } = require('child_process');

try {
  const output = execSync('node app.js', {
    timeout: 1000,
    env: { ...process.env, PORT: '8090' }
  }).toString();

  if (!output.includes('Server is running on port 8090')) {
    throw new Error('Server did not start correctly');
  }

  process.stdout.write('Sample unit test passed\n');
} catch (error) {
  process.stderr.write(`Sample unit test failed: ${error.message}\n`);
  process.exit(1);
}

// Made with Bob
