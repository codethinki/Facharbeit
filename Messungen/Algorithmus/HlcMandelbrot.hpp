#pragma once
#include <cstdint>
#include <utils/graphics.hpp>


namespace hlc {
class HlcMandelbrot {
public:
	void calc();

	HlcMandelbrot(float x_start,
		float y_start,
		float x_end,
		float y_end,
		int max_iterations,
		uint32_t x_resolution,
		uint32_t y_resolution,
		int gradient_detail,
		uint8_t* arr);
	~HlcMandelbrot();
	uint8_t* img;

private:
	unique_ptr<color::Gradient> gradient;
	float xStart, yStart, xEnd, yEnd;
	int maxIterations;
	uint32_t xResolution, yResolution;
	int gradientDetail;
};
}
