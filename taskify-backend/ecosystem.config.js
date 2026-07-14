// ── PM2 Ecosystem Configuration ───────────────────────────────────────────
// https://pm2.keymetrics.io/docs/usage/application-declaration/
//
// Usage:
//   pm2 start ecosystem.config.js          # cluster mode (all envs)
//   pm2 start ecosystem.config.js --env production
//   pm2 monit                              # live monitoring
//   pm2 dump; pm2 startup                  # resurrect on reboot

module.exports = {
  apps: [
    {
      name: 'tasknest-api',
      script: './cluster.js',
      instances: process.env.WORKERS === 'auto' ? 0 : parseInt(process.env.WORKERS) || 0,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'development',
        PORT: 5050,
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 5050,
      },
      // ── Memory & Reliability ─────────────────────────────────────────
      max_memory_restart: '512M',
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 2000,
      kill_timeout: 5000,
      // ── Logging ──────────────────────────────────────────────────────
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      error_file: './logs/error.log',
      out_file: './logs/out.log',
      combine_logs: true,
      // ── Monitoring ───────────────────────────────────────────────────
      watch: false,
      autorestart: true,
      // ── Garbage Collection Tuning ────────────────────────────────────
      node_args: '--max-old-space-size=4096 --gc-interval=100',
    },
    {
      name: 'tasknest-worker',
      script: './workers/standaloneWorker.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'development',
      },
      env_production: {
        NODE_ENV: 'production',
      },
      max_memory_restart: '256M',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      error_file: './logs/worker-error.log',
      out_file: './logs/worker-out.log',
    },
  ],
};
