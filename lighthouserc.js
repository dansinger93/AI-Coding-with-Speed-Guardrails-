module.exports = {
  ci: {
    collect: {
      numberOfRuns: 1,
      url: ['http://localhost:3000'],
      startServerCommand: 'npm run start',
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 1 }],
        'categories:accessibility': ['warn', { minScore: 1 }],
        'categories:best-practices': ['warn', { minScore: 1 }],
        'categories:seo': ['warn', { minScore: 1 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
