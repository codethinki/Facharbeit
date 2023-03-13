#pragma once
#include <cstdint>

class KochCurve {
public:
	enum Type { TRIANGLE, RECT };

	KochCurve(const Type type, const int iterations, const int probes, const int test_plane_size, uint8_t* arr) : type{type},
		iterations{iterations},
		probes{probes},
		testPlaneSize{test_plane_size},
		pix{arr} {}
	void drawCurve();

	Type type;
	int iterations, probes, testPlaneSize;
	long lineCounter = 1;
	uint8_t* pix;
	void pixLine(float x1, float y1, float x2, float y2);
	void triangularKochCurve(float x1, float y1, float size, float angle, uint32_t n);
	void squareKochCurve(float x1, float y1, float size, float angle, int n);
	void printLineCounter();
};
