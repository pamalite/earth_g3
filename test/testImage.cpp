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

#include "testImage.h"
#include "Image.h"

testImage::testImage() : Tester("Image")
{
	test();
};

void testImage::test()
{
	Image *image1 = Image::construct("test/templateImages/8x8.sgi");
	if (checkNotNULL("test 0", image1)) {
		checkEqual("test 1", image1->path().fullName(),
			"test/templateImages/8x8.sgi");
		checkEqual("test 2", image1->size().getKBytes(), 0.89);
		checkEqual("test 3", image1->formatString(), "SGI");
		checkEqual("test 4", image1->dim().width(), 8);
		checkEqual("test 5", image1->dim().height(), 8);
		delete image1;
	}
	
	Image *image2 = Image::construct("test/templateImages/8x8.tiff");
	if (checkNotNULL("test 5b", image2)) {
		checkEqual("test 6", image2->path().fullName(),
			"test/templateImages/8x8.tiff");
		checkEqual("test 7", image2->size().getKBytes(), 0.39);
		checkEqual("test 8", image2->formatString(), "TIFF");
		checkEqual("test 9", image2->dim().width(), 8);
		checkEqual("test 10", image2->dim().height(), 8);
		delete image2;
	}
		
	// *** FIT File format currently untested ****
	// *** PRMANZ File format currently untested ****
	// *** PRTEX File format currently untested ****
	
	Image *image3 = Image::construct("test/templateImages/8x8.gif");
	if (checkNotNULL("test 10b", image3)) {
		checkEqual("test 11", image3->path().fullName(),
			"test/templateImages/8x8.gif");
		checkEqual("test 12", image3->size().getKBytes(), 0.83);
		checkEqual("test 13", image3->formatString(), "GIF");
		checkEqual("test 14", image3->dim().width(), 8);
		checkEqual("test 15", image3->dim().height(), 8);
		delete image3;
	}
	
	Image *image4 = Image::construct("test/templateImages/8x8.cin");
	if (checkNotNULL("test 16a", image4)) {
		checkEqual("test 16b", image4->path().fullName(),
			"test/templateImages/8x8.cin");
		checkEqual("test 16c", image4->size().getKBytes(), 2.25);
		checkEqual("test 16d", image4->formatString(), "Cineon");
		checkEqual("test 16e", image4->dim().width(), 8);
		checkEqual("test 16f", image4->dim().height(), 8);
		delete image4;
	}
		
	Image *image5 = Image::construct("test/templateImages/8x8.iff");
	if (checkNotNULL("test 17a", image5)) {
		checkEqual("test 17b", image5->path().fullName(),
			"test/templateImages/8x8.iff");
		checkEqual("test 17c", image5->size().getKBytes(), 0.41);
		checkEqual("test 17d", image5->formatString(), "IFF");
		checkEqual("test 17e", image5->dim().width(), 8);
		checkEqual("test 17f", image5->dim().height(), 8);
		delete image5;
	}
		
}
