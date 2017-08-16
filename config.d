// Written in the D programming language.
/*
 * dmd 2.070.0 - 2.071.0
 *
 * Copyright Seiji Fujita 2016.
 * Distributed under the Boost Software License, Version 1.0.
 * http://www.boost.org/LICENSE_1_0.txt
 */

/*
 .Associative Arrays(hashmap, hashtable, 連想配列)を使用してプログラムの内のデータの保存をする
 .ファイルの保存には JSON 使用する

*/
module config;

import std.stdio;
import std.conv;
import std.json;
import std.exception;
import std.file;
import std.path;


import debuglog;

version = USE_BACKUP;

enum string CONFIG_EXT = ".conf";
enum string BACKUP_EXT = ".bakup";
enum string TEMP_EXT   = ".temp";

enum string ProductName       = "ProductName";
enum string ProductName_Value = "PRODUCT";

enum string ProductVersion       = "ProductVersion";
enum string ProductVersion_Value = "0.1.0a"; // The human identification version numbers 

enum string ProductReleaseBuild    = "ProductReleaseBuild";
enum long ProductReleaseBuild_Value = 1000; // The updater identification version numbers

enum string Product_BuildDATE = "Product_BuildDATE";
enum string Product_BuildDMD  = "Product_BuildDMD";
//
enum string LastPath     = "LastPath";
enum string BookmarkData = "BookmarkData";
//

static Config cf;

void ConfigInit() {
	cf = new Config();
}
void SaveConfig() {
	cf.saveConfig();
}

class Config
{
private:
	string[string]		stringValue;  // STRING
	long[string]		integerValue; // INTEGER
	string[][string]	stringArray;  // STRING ARRAY
	long[][string] 		integerArray; // INTEGER ARRAY
	
	string _productPath;
	string _productName;
	string _configFilePath;
	string _configTempPath;
	string _configBackPath;
	
	void init() {
		setString(ProductName, ProductName_Value);
		setString(ProductVersion, ProductVersion_Value);
		setInteger(ProductReleaseBuild, ProductReleaseBuild_Value);
		setString(Product_BuildDATE, __TIMESTAMP__);
		setString(Product_BuildDMD,  __VENDOR__ ~ " " ~ to!string(__VERSION__));
	}
	
	void setupPath() {
		string appPath = thisExePath();
		_productPath = dirName(appPath); // path/dir/file.ext -> path/dir
		
		version (Windows) {
			_productName = baseName(stripExtension(appPath));
			_configFilePath = stripExtension(appPath) ~ CONFIG_EXT;
		} else {
			_productName = baseName(appPath);
			_configFilePath = appPath ~ CONFIG_EXT;
		}
		_configTempPath = _configFilePath ~ TEMP_EXT;
		_configBackPath = _configFilePath ~ BACKUP_EXT;
    }
	
	void logPrint() {
		dlog("_configFilePath: ", _configFilePath);
		dlog("_configBackPath: ", _configBackPath);
		dlog("_configTempPath: ", _configTempPath);
		
		dlog("_productPath:    ", _productPath);
		dlog("_productName:    ", _productName);
		dlog("stringValue: ", stringValue);
		dlog("integerValue: ", integerValue);
		foreach(key; stringArray.keys)
			dlog("stringArray: ", key, ":", stringArray[key]);
		foreach(key; integerArray.keys)
			dlog("integerArray: ", key, ":", integerArray[key]);
	}

public:
	this() {
		init();
		setupPath();
	}
	// config
	this(string configData) {
		init();
		parseConfig(configData);
	}

	//
	void setString(string key, string value) {
		stringValue[key] = value;
	}
	void setInteger(string key, int value) {
		integerValue[key] = cast(long) value;
	}
	void setInteger(string key, long value) {
		integerValue[key] = value;
	}
	void setStringArray(string key, string[] value) {
		stringArray[key] = value;
	}
	void setIntegerArray(string key, int[] value) {
		long[] array;
		foreach(v; value) {
			long i = v;
			array ~= i;
		}
		integerArray[key] = array;
	}
	void setIntegerArray(string key, long[] value) {
		integerArray[key] = value;
	}
	// get string
	bool chkStringKey(string key) {
		return (key in stringValue) ? true : false;
	}
	string getString(string key) {
		return stringValue[key];
	}
	bool getString(string key, ref string value) {
		bool result = false;
		if (key in stringValue) {
			value  = stringValue[key];
			result = true;
		}
		return result;
	}
	// integer
	bool chkIntegerKey(string key) {
		return (key in integerValue) ? true : false;
	}
	long getInteger(string key) {
		return integerValue[key];
	}
	bool getInteger(string key, ref int value) {
		bool result = false;
		if (key in integerValue) {
			value  = cast(int)integerValue[key];
			result = true;
		}
		return result;
	}
	bool getInteger(string key, ref long value) {
		bool result = false;
		if (key in integerValue) {
			value  = integerValue[key];
			result = true;
		}
		return result;
	}
	// string array
	bool chkStringArrayKey(string key) {
		return (key in stringArray) ? true : false;
	}
	string[] getStringArray(string key) {
		return stringArray[key];
	}
	bool getStringArray(string key, ref string[] value) {
		bool result = false;
		if (key in stringArray) {
			value = stringArray[key];
			result = true;
		}
		return result;
	}
	// integer array
	bool chkIntegerArrayKey(string key) {
		return (key in integerArray) ? true : false;
	}
	long[] getIntegerArray(string key) {
		return integerArray[key];
	}
	bool getIntegerArray(string key, ref long[] value) {
		bool result = false;
		if (key in integerArray) {
			value = integerArray[key];
			result = true;
		}
		return result;
	}
	bool getIntegerArray(string key, ref int[] value) {
		bool result = false;
		if (key in integerArray) {
			int[] intvalue;
			foreach (v ; integerArray[key]) {
				intvalue ~= to!int(v);
			}
			value = intvalue;
			result = true;
		}
		return result;
	}
	// key remove
	void stringValueRemoveKey(string key) {
		stringValue.remove(key);
	}
	void integerValueRemoveKey(string key) {
		integerValue.remove(key);
	}
	void stringArrayRemoveKey(string key) {
		stringArray.remove(key);
	}
	void integerArrayRmoveKey(string key) {
		integerArray.remove(key);
	}
// @---------------------------------------------------------------------------
	// test data enum string updateURL = "https://raw.githubusercontent.com/SeijiFujita/updater/master/updater.conf";
	void getUrlparseConfig(string url) {
		import std.net.curl;
		parseConfig(cast(string) std.net.curl.get(url));
	}
	string getUniqueString() {
		import std.datetime.systime;
		import std.format;
		SysTime ctime = Clock.currTime();
		with(ctime) {
			return format("%04d%02d%02d-%02d%02d%02d.%03d",
				year,
				month,
				day,
				hour,
				minute,
				second,
				ctime.fracSecs.total!"msecs");
		}
	}
	//
	void getUrlConfig(string url) {
		import std.net.curl;
		string tempPath = tempDir() ~ "update-" ~ getUniqueString();
		mkdirRecurse(tempPath);
		string configPath = buildPath(tempPath, "nconfig.json");
		writeln("url = ", url);
		writeln("configPath = ", configPath);
		// write(configPath, std.net.curl.get(url);
		std.net.curl.download(url, configPath);
		if (!loadConfig(configPath)) {
			assert(false, "loadConfig: JSON Errror" ~ __FILE__ ~ ":" ~ to!string(__LINE__));
		}
		//exRemove(configPath);
	}
// @---------------------------------------------------------------------------
	// ProductName
	void setProductName(string s) { // @property {
		setString(ProductName, s);
	}
	bool getProductName(ref string s) {
		return getString(ProductName, s);
	}
	// ProductVersion
	bool getProductVersion(ref string s) {
		return getString(ProductVersion, s);
	}
	// ProductReleaseBuild_No
	bool getProductReleaseBuild(ref long l) {
		return getInteger(ProductReleaseBuild, l);
	}
	// LastPath
	void setLastPath(string path) {
		setString(LastPath, path);
	}
	bool getLastPath(ref string path) {
		return getString(LastPath, path);
	}
	// bookmarks
	void setBookmarks(string[] data) {
		setStringArray(BookmarkData, data);
	}
	bool getBookmarks(ref string[] data) {
		return getStringArray(BookmarkData, data);
	}
	void BookmarksDataClear() {
		stringArray.remove(BookmarkData);
	}
// @---------------------------------------------------------------------------
	// https://ja.wikipedia.org/wiki/JavaScript_Object_Notation
	// JSONのテキストエンコーディングは基本UTF-8 らしい
	//	enum CODE_CR = "\n"; // 10, 0x0A
	//	enum CODE_LF = "\r"; // 13, 0x0D
	//	enum CODE_CRLF = "\n\r"; // 0x0A,0x0D
	//	enum CODE_TAB = "\t"; // HT, 0x09
	
	string readerbleJson(string json) {
		string result;
		bool skip_flag;
		foreach (v ; json) {
			if (skip_flag) {
				if (v == ']') {
					skip_flag = false;
				}
				result ~= v;
				continue;
			}
			if (v == '[') {
				skip_flag = true;
			} else if (v == ',') {
				result ~= ",\n\t";
				continue;
			} else if (v == '{') {
				result ~= "{\n\t";
				continue;
			} else if (v == '}') {
				result ~= "\n";
			}
			result ~= v;
		}
		return result;
		// return result.dup;
	}
		
	void loadConfig() {
		if (!loadConfig(_configFilePath)) {
			saveConfig();
			loadConfig(_configFilePath);
		}
	}
	
	bool loadConfig(string fileName) {
		bool result;
		if (exists(fileName)) {
			parseConfig(cast(string) std.file.read(fileName));
			result = true;
		}
		return result;
	}
	
	void parseConfig(string json) {
		JSONValue jroot = parseJSON(json);
		enforce(jroot.type == JSON_TYPE.OBJECT, "jroot.type == JSON_TYPE.OBJECT");
		foreach(key; jroot.object.keys) {
			if (jroot[key].type == JSON_TYPE.STRING) {
				setString(key, jroot[key].str);
			} else if (jroot[key].type == JSON_TYPE.INTEGER) {
				setInteger(key, jroot[key].integer);
			} else if (jroot[key].type == JSON_TYPE.ARRAY) {
				if (jroot[key][0].type == JSON_TYPE.STRING) {
					string[] str;
					foreach(v; jroot[key].array) {
						str ~= v.str();
					}
					setStringArray(key, str);
				} else if (jroot[key][0].type == JSON_TYPE.INTEGER) {
					long[] l;
					foreach(v; jroot[key].array) {
						l ~= v.integer();
					}
					setIntegerArray(key, l);
				} else {
					assert(false, "loadConfig: JSON Array errror" ~ __FILE__ ~ ":" ~ to!string(__LINE__));
				}
				//
			// } else if (jroot[key].type == JSON_TYPE.UINTEGER) {
			}
			else {
				assert(false, "loadConfig: JSON Errror" ~ __FILE__ ~ ":" ~ to!string(__LINE__));
					// (jroot[key].type == JSON_TYPE.UINTEGER)
					// (jroot[key].type == JSON_TYPE.FLOAT)
					// (jroot[key].type == JSON_TYPE.OBJECT)
					// (jroot[key].type == JSON_TYPE.TRUE)
					// (jroot[key].type == JSON_TYPE.FALSE)
					// (jroot[key].type == JSON_TYPE.NULL)
			}
		}
	}
	void saveConfig() {
		// conf to json
	    JSONValue jroot = ["@config": "type01"];	// dummy
		foreach (key; stringValue.keys) {
		    jroot[key] = getString(key);
		}
		foreach (key; integerValue.keys) {
			jroot[key] = getInteger(key);
		}
		foreach (key; stringArray.keys) {
			jroot[key] = getStringArray(key);
		}
		foreach (key; integerArray.keys) {
			jroot[key] = getIntegerArray(key);
		}
		// writeln(readerbleJson(jroot.toString()));
		
		exRemove(_configTempPath);
		std.file.write(_configTempPath, readerbleJson(jroot.toString()));
		
		version (USE_BACKUP) {
			exRename(_configFilePath, _configBackPath);
			exRename(_configTempPath, _configFilePath);
		} else {
			exRename(_configTempPath, _configFilePath);
		}
	}
	private void exRemove(string f) {
		if (exists(f)) {
			remove(f);
		}
	}
	private void exRename(string from, string to) {
		if (exists(from)) {
			exRemove(to);
			rename(from, to);
		}
	}
}


version (none) {

void main()
{

	Config conf = new Config;
	conf.set("test_flag", 1);
	conf.set("test_string", "stringValue");
	conf.saveConfig();
}

/++
enum JSON_TYPE : byte {
    /// Indicates the type of a $(D JSONValue).
    NULL,
    STRING,  /// ditto
    INTEGER, /// ditto
    UINTEGER,/// ditto
    FLOAT,   /// ditto
    OBJECT,  /// ditto
    ARRAY,   /// ditto
    TRUE,    /// ditto
    FALSE    /// ditto
}
++/
// std.json.d(281)
// private void assign(T)(T arg)

JSON_TYPE jsonType(T)(T arg)
{
	JSON_TYPE result;
	
	static if(is(T : typeof(null))) {
		result = JSON_TYPE.NULL;
	}
	else static if(is(T : string)) {
		result = JSON_TYPE.STRING;
	}
	else static if(is(T : bool)) {
		result = arg ? JSON_TYPE.TRUE : JSON_TYPE.FALSE;
	}
	else static if(is(T : ulong) && isUnsigned!T) {
		result = JSON_TYPE.UINTEGER;
	}
	else static if(is(T : long)) {
		result = JSON_TYPE.INTEGER;
	}
	else static if(isFloatingPoint!T) {
		result = JSON_TYPE.FLOAT;
	}
	else static if(is(T : Value[Key], Key, Value)) {
		static assert(is(Key : string), "AA key must be string");
		result = JSON_TYPE.OBJECT;
	}
	return result;
}
} //

