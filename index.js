const nativeModule = process.platform === 'darwin' ? require('bindings')('main.node') : undefined;

const signInWithApple = async (mainWindow) => {
  if (process.platform !== 'darwin') {
    throw new Error('node-mac-sign-in-with-apple only works on macOS')
  }

  return new Promise((resolve, reject) => {
    nativeModule.signInWithApple((result) => {
      if (result.is_error === 'true') {
        delete result.is_error;
        const error = new Error(result.message)
        error.code = result.code
        reject(error);
        return;
      }

      delete result.is_error;
      resolve(result);
    }, mainWindow);
  })
};

function requestReview () {
  if (process.platform !== 'darwin') {
    throw new Error('This module only works on macOS')
  }
  nativeModule.requestReview()
}

module.exports = {
  signInWithApple,
  requestReview
};
