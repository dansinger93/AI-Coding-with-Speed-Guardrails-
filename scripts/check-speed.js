const { execSync } = require('child_process');

console.log('🚀 Running AI Performance Guardrails...');

try {
  console.log('📦 Building project...');
  // Adjust the build command if you are not using Next.js
  execSync('npm run build', { stdio: 'inherit' });

  console.log('⚡ Running Lighthouse CI...');
  // Runs Lighthouse CI and asserts the conditions in lighthouserc.js
  execSync('npx lhci autorun', { stdio: 'inherit' });

  console.log('✅ Performance check passed! Code is optimized.');
} catch (error) {
  console.error('\n❌ Performance check failed!');
  console.error('AI, please review the Lighthouse report above, identify the bottleneck, and optimize the code.');
  process.exit(1);
}
