//  Copyright (C) 2001, 2002 Matthew Landauer. All Rights Reserved.
//  
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of version 2 of the GNU General Public License as
//  published by the Free Software Foundation.
//
//  This program is distributed in the hope that it would be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Further, any
//  license provided herein, whether implied or otherwise, is limited to
//  this program in accordance with the express provisions of the GNU
//  General Public License.  Patent licenses, if any, provided herein do not
//  apply to combinations of this program with other product or programs, or
//  any other product whatsoever.  This program is distributed without any
//  warranty that the program is delivered free of the rightful claim of any
//  third person by way of infringement or the like.  See the GNU General
//  Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write the Free Software Foundation, Inc., 59
//  Temple Place - Suite 330, Boston MA 02111-1307, USA.
//
// $Id$

#include <iostream>
#include "testDir.h"
#include "SpDir.h"

testDir::testDir() : Tester("Dir")
{
	test();
};

void testDir::test()
{
	Dir dir("test/templateImages/");
	checkEqual("test 1", dir.path().fullName(),
		"test/templateImages");
	// Think of some way to test the modification dates automatically
	// Check that this user owns the files
	Uid u = Uid::current();
	checkEqual("test 2", dir.uid().name(), u.name());
	Gid g = Gid::current();
	checkEqual("test 3", dir.gid().name(), g.name());
	checkEqualBool("test 4", dir.valid(), true);
	std::vector<FsObjectHandle> ls = dir.ls();
	if (checkEqual("ls test 0", ls.size(), 13)) {
		std::vector<FsObjectHandle>::iterator a = ls.begin();
		checkImage("ls test 1", *(a++), "test/templateImages/2x2.gif", "GIF");
		checkNotImage("ls test 2", *(a++), "test/templateImages/2x2.jpg");
		checkImage("ls test 3", *(a++), "test/templateImages/2x2.sgi", "SGI");
		checkImage("ls test 4", *(a++), "test/templateImages/2x2.tiff", "TIFF");
		checkImage("ls test 5", *(a++), "test/templateImages/4x4.gif", "GIF");		
		checkNotImage("ls test 6", *(a++), "test/templateImages/4x4.jpg");						
		checkImage("ls test 7", *(a++), "test/templateImages/4x4.sgi", "SGI");		
		checkImage("ls test 8", *(a++), "test/templateImages/4x4.tiff", "TIFF");		
		checkImage("ls test 9", *(a++), "test/templateImages/8x8.gif", "GIF");		
		checkNotImage("ls test 10", *(a++), "test/templateImages/8x8.jpg");		
		checkImage("ls test 11", *(a++), "test/templateImages/8x8.sgi", "SGI");		
		checkImage("ls test 12", *(a++), "test/templateImages/8x8.tiff", "TIFF");		
		checkDir("ls test 13", *(a++), "test/templateImages/CVS");		
	}
	// Try doing an ls on a non-existant directory
	Dir dirNotExist("test/whatASillyFella");
	checkEqualBool("non-existant test 1", dirNotExist.valid(), false);
	std::vector<FsObjectHandle> lsNotExist = dirNotExist.ls();
	checkEqual("non-existant test 2", lsNotExist.size(), 0);
}

void testDir::checkImage(std::string n, FsObjectHandle o, std::string fileName, std::string formatString) {
	checkEqual(n + "a",  o->path().fullName(), fileName);
	Image *i = dynamic_cast<Image *>(o.pointer());
	if (Tester::checkNotNULL(n + "b", i))
		checkEqual(n + "c",  i->formatString(), formatString);		
}

void testDir::checkNotImage(std::string n, FsObjectHandle o, std::string fileName) {
	checkEqual(n + "a",  o->path().fullName(), fileName);
	checkNULL(n + "b",  dynamic_cast<Image *>(o.pointer()));
}

void testDir::checkDir(std::string n, FsObjectHandle o, std::string fileName) {
	checkEqual(n + "a",  o->path().fullName(), fileName);
	checkNotNULL(n + "b",  dynamic_cast<Dir *>(o.pointer()));
}