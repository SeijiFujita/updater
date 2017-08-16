//
// update 
//
// 
// In microsoft windows 10, it seems that executable files of 
// file name update.exe(test-update.exe or etc...) are stopped from 
// running from windows operating system.
//
module updapp;

import std.stdio;

import config;
import debuglog;

enum string currntConfigPath = "currnetConfig.json";
enum string updateURL = "https://raw.githubusercontent.com/SeijiFujita/updater/master/updatetConfig.json";

bool checkUpdate() {
	import std.net.curl;
	import std.file;
	bool result;
	Config curcf = new Config(cast(string) read(currntConfigPath));
	Config newcf = new Config(cast(string) get(updateURL));
	
	long curver, newver;
	if (curcf.getProductReleaseBuild(curver) && newcf.getProductReleaseBuild(newver)) {
		writeln("current version = ", curver);
		writeln("net new version = ", newver);
		if (newver > curver) { 
			// update...
			writeln("go update!");
			result = true;
		}
	}
	return result;
}


int main() {
	try {
		writeln("== updater == ");
		if (checkUpdate()) {
			
		}
	}
	catch (Exception e) {
		writeln(e.msg);
	}
	return 0;
}

