const { execSync } = require('child_process');

// Check if lighthouserc.js is targeting a production URL or localhost
const lhConfig = require('../lighthouserc.js');
const urls = lhConfig?.ci?.collect?.url ?? [];
const hasStartServerCommand = !!lhConfig?.ci?.collect?.startServerCommand;
const isProductionUrl = urls.some((u) => u.startsWith('https://'));

console.log('Running AI Performance Guardrails...');

try {
  if (isProductionUrl) {
    // Production URL: skip the build step — we are auditing the live site directly
    console.log(`Auditing production URL(s): ${urls.join(', ')}`);
    console.log('Skipping build step (not needed for production URL testing).');
  } else {
    // Localhost: build first so Lighthouse sees the production bundle, not dev mode
    // Dev mode bundles are unminified and will fail performance checks artificially
    console.log('Building project (required before testing localhost)...');
    // Adjust the build command if you are not using Next.js
    execSync('npm run build', { stdio: 'inherit' });
  }

  console.log('Running Lighthouse CI...');
  // Runs Lighthouse CI and asserts the conditions in lighthouserc.js
  execSync('npx lhci autorun', { stdio: 'inherit' });

  console.log('Performance check passed! Code is optimized.');
} catch (error) {
  console.error('\nPerformance check failed!');
  console.error('Review the Lighthouse report above, identify the bottleneck, and optimize the code.');
  process.exit(1);
}
