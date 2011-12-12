var http = require('http'),
	fs = require('fs');

var options = {
  host: 'localhost',
  port: 3000,
  path: '/foobar',
  method: 'POST',
  headers: {
  	'Content-Type': 'application/x-www-form-urlencoded'
  }
};


fs.readFile('example.md', 'utf8', function(err, data){
	var req = http.request(options, function(res) {
	  console.log('STATUS: ' + res.statusCode);
	  console.log('HEADERS: ' + JSON.stringify(res.headers));
	  res.setEncoding('utf8');
	  res.on('data', function (chunk) {
	    console.log('BODY: ' + chunk);
	  });
	});

	// write data to request body
	req.write("post="+encodeURIComponent(data));
	req.end();
});


//request.write("x="+encodeURIComponent(toServ))