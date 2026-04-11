module.exports = {
  ci: {
    collect: {
      // 3 runs gives reliable averages — single runs are too noisy (±10 points)
      numberOfRuns: 3,

      // OPTION A: Test against production URL (recommended — matches real user conditions)
      // No startServerCommand needed when using a live URL.
      url: ['https://your-production-url.com'],

      // OPTION B: Test localhost (uncomment and remove the url above if testing locally)
      // WARNING: localhost scores can differ from production by 10-30 points due to
      // missing CDN, compression, HTTP/2, and real network conditions.
      // url: ['http://localhost:3000'],
      // startServerCommand: 'npm run start',
    },
    assert: {
      assertions: {
        // All four categories are errors — warn means CI passes even when broken
        'categories:performance': ['error', { minScore: 1 }],
        'categories:accessibility': ['error', { minScore: 1 }],
        'categories:best-practices': ['error', { minScore: 1 }],
        'categories:seo': ['error', { minScore: 1 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
