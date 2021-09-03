const gulp = require('gulp');
const util = require('gulp-util');
const gulpConnect = require('gulp-connect');
const express = require('express');
const cors = require('cors');
const path = require('path');
const exec = require('child_process').exec;
const portfinder = require('portfinder');
const swaggerRepo = require('swagger-repo');

const DIST_DIR = 'web_deploy';
const SPEC_DIR = 'spec';

gulp.task('edit', function(done) {
  portfinder.getPort({port: 5000}, function (err, port) {
    let app = express();
    app.use(swaggerRepo.swaggerEditorMiddleware());
    app.listen(port);
    util.log(util.colors.green('swagger-editor started http://localhost:' + port));
  });
  done()
});

gulp.task('build', function (cb) {
  exec('npm run build', function (err, stdout, stderr) {
    console.log(stderr);
    cb(err)
  });
});

gulp.task('reload', gulp.series('build', function (done) {
  gulp.src(DIST_DIR).pipe(gulpConnect.reload());
  done()
}));

gulp.task('watch', function (done) {
  gulp.watch([`${SPEC_DIR}/**/*`, 'web/**/*'], gulp.series('reload'));
  done()
});

gulp.task('ui', function (done) {
  portfinder.getPort({port: 3000}, function (err, port) {
    gulpConnect.server({
      root: [DIST_DIR],
      livereload: true,
      port: port,
      middleware: function (gulpConnect, opt) {
        return [
          cors()
        ]
      }
    });
    done()
  });
});

gulp.task('serve', gulp.series('build', gulp.parallel('ui', 'edit', 'watch'), function (done) {
  done()
}));
