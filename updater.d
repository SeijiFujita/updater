//
// update.d
//

module update;

import std.stdio;

import config;

// import debuglog;

enum string updateURL = "github.com/SeijiFujita/PRODUT/update.json";
//enum string localUpdateFilename = "bin\\update.json";

bool checkUpdate() {
	bool result;
	long current, ver;
	Config newcf = new Config(updateURL);
	if (newcf.getProductReleaseBuild(ver) && cf.getProductReleaseBuild(current)) {
		writeln("current version = ", current);
		writeln("net new version = ", ver);
		if (ver > current) { 
			// update...
			result = true;
		}
	}
	return result;
}



int main() {
	try {
		ConfigInit();
		SaveConfig();
		if (checkUpdate()) {

		}
	}
	catch (Exception e) {
		writeln(e.msg);
	}
	return 0;
}
