// pkgparser.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include "stdafx.h"
#include "pkgParser.h"

int _tmain(int argc, _TCHAR* argv[])
{
	pkgParser parser;
	parser.openfile("E:\\workspace\\SVN\\CardGame_1\\Main\\client\\tools\\Game_tolua++\\DataTableManager.pkg");
	parser.createData();
	const std::map<std::string,pkgClass&>& ret = parser.search("serv");
	return 0;
}

