define(function (require) {

  'use strict';

  var _parseFile = function (file) {
    return {
      id: file.id,
      name: file.name,
      desc: file.desc,
      year: file.year,
      artworkLarge: file.artwork_large,
      artworkSmall: file.artwork_small,
      artworkXSmall: file.artwork_xsmall,
      fileType: file.file_type,
      fileSize: file.file_size,
      uploaded: file.uploaded,
      uploadedReadable: file.uploaded_readable
    }
  },

  FileParser = {
    parse: function (files) {
      for (var i = 0; i < files.length; i++) {
        files[i] = _parseFile(files[i]);
      };
      return files;
    }
  };

  return FileParser;

});
