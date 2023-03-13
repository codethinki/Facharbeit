#include "HlcMandelbrot.hpp"
#include "utils/math.hpp"
#include <vector>
#include <thread>
#include <stb/stb_image_write.h>
#include <iostream>
#include <chrono>


namespace hlc {
using namespace std;

void HlcMandelbrot::calc() {
	auto calcSegment = [this](const int y, const int from, const int length) {
		const uint32_t pixelRow = xResolution * y;
		const float imgCRef = map(static_cast<float>(y), 0.f, static_cast<float>(yResolution), yStart, yEnd);

		for(uint32_t x = from; x < xResolution && x < length; x++) {
			const float imgC = imgCRef, realC = map(static_cast<float>(x), 0.f, static_cast<float>(xResolution), xStart, xEnd);

			float realZ = realC, imgZ = imgCRef;
			float c = 0;
			while(c < maxIterations && realZ * realZ + imgZ * imgZ < 4) {
				const float buff = realZ * realZ - imgZ * imgZ + realC;
				imgZ = imgZ * realZ * 2 + imgC;
				realZ = buff;
				c++;
			}
			const auto color = gradient->colors[static_cast<int>((gradientDetail - 1) * (c / maxIterations))];
			const uint32_t pixel = (pixelRow + x) * 3;
			img[pixel] = static_cast<uint8_t>(color.x);
			img[pixel + 1] = static_cast<uint8_t>(color.y);
			img[pixel + 2] = static_cast<uint8_t>(color.z);
		}
	};

	vector<thread> threads;
	int counter = 0;

	cout << "mandelbrot calculation started" << endl;
	auto start = std::chrono::high_resolution_clock::now();

	while(counter < yResolution || !threads.empty()) {
		if(threads.size() <= 100 && counter < yResolution) {
			threads.emplace_back(calcSegment, counter, 0, xResolution);
			counter++;
		}
		else {
			threads[0].join();
			threads.erase(threads.begin());
		}
	}
	for(auto& thread : threads) thread.join();

	cout << "calculation of " << yResolution * xResolution << " Points with " << maxIterations << " iterations each finished in " << chrono::duration<
		float>(std::chrono::high_resolution_clock::now() - start).count() << "s" << endl;
	cout << "gradient detail: " << gradientDetail << endl;
}

HlcMandelbrot::HlcMandelbrot(const float x_start,
	const float y_start,
	const float x_end,
	const float y_end,
	const int max_iterations,
	const uint32_t x_resolution,
	const uint32_t y_resolution,
	int gradient_detail,
	uint8_t* arr) : xStart{x_start},
	yStart{y_start},
	xEnd{x_end},
	yEnd{y_end},
	maxIterations{max_iterations},
	xResolution{x_resolution},
	yResolution{y_resolution},
	gradientDetail{gradient_detail},
	img{arr} {
	gradient = make_unique<color::Gradient>(gradient_detail,
		vector<glm::vec3>{glm::vec3{0, 0, 0}, {255, 0, 0}, {0.8 * 255, 0.8 * 255, 0}, {255, 255, 0}, {0.7 * 255, 0, 0}, {0, 0, 0}});
	gradient->makeExpLin(1.3);
	//gradient = make_unique<color::Gradient>(gradient_detail, vector<glm::vec3>{{0, 0, 0}, {255, 0, 127}, {0.8 * 255, 0, 0.8* 255}, {255, 0, 255}, {0, 0, 0}});
		//gradient = make_unique<color::Gradient>(gradient_detail, vector<glm::vec3>{{255, 255, 255}, {255, 0, 127}, {0.8 * 255, 0, 0.8* 255}, {0.3 * 255, 0, 0.3 * 255}, {255, 255, 255}});

	//gradient->makeExpLin(3.f);
	ranges::reverse(gradient->colors);
}
HlcMandelbrot::~HlcMandelbrot() {}

}
