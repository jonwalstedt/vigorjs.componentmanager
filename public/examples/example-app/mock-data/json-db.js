// json-db.js
var fileTypes = ['music', 'photo', 'video'];
var exampleMovies = require('./example-movies');

module.exports = function() {
  var data = {},
      totalSize = 0,
      files = generateFiles();

  for (var i = 0; i < files.length; i++) {
    totalSize += files[i].file_size;
  };

  console.log('total file size: ', totalSize);
  data.users = generateUser();
  data.files = files;

  data.users[0].bytes_used = totalSize;
  return data
}


function generateUser () {
  return [{
    id: 1,
    first_name: 'Robert',
    last_name: 'Clark',
    account: 'premium',
    bytes_used: undefined,
    // profile_img: 'http://lorempixel.com/100/100/animals/',
    profile_img: 'https://unsplash.it/100/100/?random',
    // profile_img: 'https://unsplash.it/100/100',
    // profile_img: 'https://placeholdit.imgix.net/~text?txtsize=14&txt=logo&w=100&h=100&txttrack=0',
    logged_in: true
  }]
}

function generateFiles () {
  var files = [],
      nrOfFiles = 220;

  for (var i = 0; i < nrOfFiles; i++) {
    files.push(getFile(i));
  };

  return files;
}

function getFile (index) {
  var fileType = fileTypes[Math.round(Math.random() * (fileTypes.length - 1))],
      fileSize = Math.round(Math.random() * 10000000),
      artWorkLarge = 'https://unsplash.it/800/500/?image=' + index,
      artWorkSmall = 'https://unsplash.it/80/80/?image=' + index,
      uploaded = randomDate(new Date(2014, 0, 1), new Date()),
      name, desc, year;

  if (fileType == 'video') {
    var movieIndex = Math.round(Math.random() * (exampleMovies.length - 1));
    name = exampleMovies[movieIndex].title;
    desc = exampleMovies[movieIndex].desc;
    year = exampleMovies[movieIndex].year;
    fileSize = Math.round(Math.random() * 100000000);
  }

  return {
    id: index,
    name: name || 'test-' + index,
    desc: desc || 'desc-' + index,
    year: year || 'year-' + index,
    artwork_large: artWorkLarge,
    artwork_small: artWorkSmall,
    file_type: fileType,
    file_size: fileSize,
    uploaded: uploaded.getTime(),
    uploaded_readable: uploaded.toDateString()
  }
}


function randomDate (start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

