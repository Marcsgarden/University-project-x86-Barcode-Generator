#include "stdlib.h"
#include "stdio.h"
#include "string.h"

char header[54] = { 66, 77, 200, 95, 1, 0, 0, 0, 0, 0, 54, 0, 0, 0, 40, 0, 0, 0, 88, 2, 0, 0, 50, 0, 0, 0, 1, 0, 24, 0, 0, 0, 0, 0, 146, 95, 1, 0, 18, 11, 0, 0, 18, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
char bitmap[90000];
/*
const int bar_height = 25;
const int start_symbol = 104;
const int stop_symbol = 106;
*/

int index_of_symbol(unsigned char symbol);
/*{
	if ((symbol < 32) || (symbol > 127))
	{
		printf("Unsupported character: '%c'\n", symbol);
		return -1;
	}
	return symbol - 32;
}*/

int load_symbol(int index);
/*
{
	const int indices[] = { 5444, 5204, 1364, 9488, 5648, 5408, 8528, 4688, 4448, 8468, 4628, 4388, 6464, 6224, 2384, 5504, 5264, 1424, 404, 6164, 2324, 4484, 4244, 2120, 5384, 5144, 1304, 4424, 4184, 344, 9284, 1604, 1124, 9728, 9248, 1568, 8768, 8288, 608, 8708, 8228, 548, 10304, 2624, 2144, 9344, 1664, 1184, 1160, 2564, 2084, 8324, 644, 2180, 9224, 1544, 1064, 8264, 584, 104, 200, 788, 44, 13568, 5888, 13328, 1808, 5168, 1328, 12608, 4928, 12368, 848, 4208, 368, 308, 12308, 140, 4148, 224, 7424, 7184, 3344, 4544, 4304, 464, 4364, 4124, 284, 3140, 1220, 1100, 11264, 3584, 3104, 8384, 704, 8204, 524, 3200, 2240, 3080, 2060, 4868, 12548, 6404, 16548 };
	return indces[index];
}
*/

void draw_rect(unsigned char *img, int x0, int y0, int x1, int y1);
/*{
	for (int y = y0; y < y1; ++y)
	{
		char* scanline = img + y * 1800;
		for (int x = x0; x < x1; ++x)
		{
			char* cursor = scanline + x * 3;
			*cursor++ = 0x00;
			*cursor++ = 0x00;
			*cursor = 0x00;
		}
	}
}*/

int draw_symbol(unsigned char *img, int bar_width, int index, int x, int y);
/*{
	int symbol = load_symbol(index);
	int steps = 6;
	if (index == 106) 
	{
		steps = 7;
	}
	for (int i = 0; i < steps; ++i)
	{
		symbol >>= 2;
		int width = ((symbol & 3) + 1) * bar_width;
		if ((i & 1) == 0)
		{
			draw_rect(img, x, y, x + width, y + bar_height);
		}
		x += width;
	}
	return x;
}*/

int encode128(unsigned char *img, int bar_width, unsigned char *text);
/*{
	int checksum = start_symbol;
	int length = strlen(text);
	int pos_y = 25 - (bar_height >> 1);
	int pos_x = 300 - ((bar_width * 35 + bar_width * 11 * length) >> 1);
	pos_x = draw_symbol(img, bar_width, start_symbol, pos_x, pos_y);
	for (int i = 0; i < length; ++i)
	{
		int index = index_of_symbol(text[i]);
		pos_x = draw_symbol(img, bar_width, index, pos_x, pos_y);
		checksum += index * (i + 1);
	}
	pos_x = draw_symbol(img, bar_width, checksum % 103, pos_x, pos_y);
	pos_x = draw_symbol(img, bar_width, stop_symbol, pos_x, pos_y);
	return 0;
}*/

int main(int argc, char** argv)
{
	if (argc != 3)
	{
		printf("Usage: %s [bar_width] [\"string to encode\"]\n", argv[0]);
		return -1;
	}
	memset(bitmap, 0xFF, 90000);
	int bar_width = atoi(argv[1]);
	int result = encode128(bitmap, bar_width, argv[2]);
	if (result == 0)
	{
		FILE* h_file = fopen("output.bmp", "wb");
		fwrite(header, 54, 1, h_file);
		fwrite(bitmap, 90000, 1, h_file);
		fclose(h_file);
	} else printf("Error %i\n");
	return result;
}