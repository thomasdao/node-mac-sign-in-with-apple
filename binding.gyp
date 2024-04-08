{
  "targets": [{
    "target_name": "main",
    "sources": [ ],
    "conditions": [
      ['OS=="mac"', {
        "sources": [
          "main.mm",
          "AppleLogin.h",
          "AppleLogin.m"
        ],
      }]
    ],
    'include_dirs': [
      "<!@(node -p \"require('node-addon-api').include\")"
    ],
    'libraries': [],
    'dependencies': [
      "<!(node -p \"require('node-addon-api').gyp\")"
    ],
    'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ],
    "cflags+": ["-fvisibility=hidden"],
    "xcode_settings": {
      # -fvisibility=hidden
      "GCC_SYMBOLS_PRIVATE_EXTERN": "YES",

      # Set minimum target version because we're building on newer
      # Same as https://github.com/nodejs/node/blob/v10.0.0/common.gypi#L416
      "MACOSX_DEPLOYMENT_TARGET": "10.15",

      "OTHER_LDFLAGS": [
        "-framework CoreFoundation",
        "-framework AppKit",
        "-framework AuthenticationServices",
        "-framework Security"
      ],
      "OTHER_CPLUSPLUSFLAGS": ["-std=c++14", "-stdlib=libc++", "-mmacosx-version-min=10.15"]
    }
  }]
}