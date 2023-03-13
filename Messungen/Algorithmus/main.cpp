#include <iostream>
#include <string>
#include <unordered_map>
#include <chrono>

#include <iostream>
#include <array>
#include <algorithm>
#include <glm/glm.hpp>
#include <glm/gtc/constants.hpp>

#include <iostream>
#include <array>
#include <algorithm>
#include <chrono>
#include <utils/graphics.hpp>
#include <utils/files.hpp>
#include <utils/graphics.hpp>

#include "KochCurve.hpp"
#include "HlcMandelbrot.hpp"
#include <opencv2/opencv.hpp>
#include <opencv2/core/utils/logger.hpp>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include<stb/stb_image_write.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>
using namespace std;

constexpr uint32_t testPlaneSize = 2000;

constexpr uint8_t colorTolerance[3] = {85, 0, 120};

uint32_t testPlaneSizeX = testPlaneSize, testPlaneSizeY = testPlaneSize;
bool draw = true;
bool verifyData = true;
constexpr int curveIterations = 13;
uint32_t testProbes = 11;


uint8_t channels = 3;
uint8_t* pix;

void saveImage(const string& image_name, const cv::Mat& image_mat) {

	const auto imageWriteStart = chrono::high_resolution_clock::now();
	cout << endl << "saving image..." << endl;
	cv::imwrite(image_name, image_mat);
	cout << "saved " << image_name << " in " << chrono::duration<float>(chrono::high_resolution_clock::now() - imageWriteStart).count() << "s " <<
		endl;
}

void verify(const cv::Mat& image) {
	const auto start = chrono::high_resolution_clock::now();

	uint32_t counter = 0;
	const uint32_t xArrSize = testPlaneSizeX * channels;

	for(uint32_t k = 0; k < testPlaneSizeY; k ++)
		for(uint32_t i = 0; i < testPlaneSizeX; i ++) {
			const uint32_t pixel = (k) * xArrSize + i * channels;

			for(int z = 0; z < channels; z++)
				if(image.data[pixel + z] > colorTolerance[z]) {
					counter++;
					for(int b = 0; b < channels; b++) image.data[pixel + b] = 255;
					break;
				}
		}

	cout << "verified " << counter << " boxes to be true in " << chrono::duration<float>(chrono::high_resolution_clock::now() - start).count() << "s"
		<< endl;

	if(draw) saveImage("verifyBigMandelbrot.png", image);
}

void mandelbrotCalculation(const float start_x, const float start_y, const float end_x, const float end_y, cv::Mat& image_mat) {
	hlc::HlcMandelbrot mandelbrot(start_x, start_y, end_x, end_y, 2036  , testPlaneSizeX, testPlaneSizeY, 5090, pix);
	//hlc::HlcMandelbrot mandelbrot(testPlaneSizeX, testPlaneSizeY, 150, image_mat.data);
	mandelbrot.calc();
	cv::cvtColor(image_mat, image_mat, cv::COLOR_BGR2RGB);
		saveImage("image.png", image_mat);
	image_mat.convertTo(image_mat, -1, 1.5, 0);
	image_mat.convertTo(image_mat, -1, 1, -10);
	image_mat.convertTo(image_mat, -1, 2, 0);
	image_mat.convertTo(image_mat, -1, 1, -40);
	image_mat.convertTo(image_mat, -1, 2, 0);
	
	cv::cvtColor(image_mat, image_mat, cv::COLOR_BGR2GRAY);
	image_mat.convertTo(image_mat, -1, 2, -20);
	channels = 1;

	cv::equalizeHist(image_mat, image_mat);
}

void drawSquare(const int x, const int y, const int length, const cv::Mat& image_mat) {
	for(int i = y; i < y + length; i++) {
		const uint32_t pixel = i * testPlaneSizeX;
		for(int k = x; k < x + length; k++) for(int c = 0; c < channels; c++) image_mat.data[pixel + k * channels + c] = 255;
	}
}

void boxAlgorithm(uint8_t* image, const int color_channels, const int probes) {
	vector<uint32_t> results(probes);

	auto boxMethod2 = [image, color_channels, &results](const int box_size, const int i) {
		uint32_t counter = 0;
		const int boxSize = box_size * color_channels;
		const uint32_t xArrSize = testPlaneSizeX * color_channels;

		for(uint32_t k = 0; k < testPlaneSizeY; k += box_size)
			for(uint32_t i = 0; i < testPlaneSizeX; i += box_size) {
				bool stop = false;
				const uint32_t newI = color_channels * i;
				for(uint32_t y = 0; y < box_size && !stop; y++) {
					if(y + k >= testPlaneSizeY) break;

					for(uint32_t x = 0; x < boxSize && !stop; x++) {
						if(x + newI >= xArrSize) break;
						const uint32_t pixel = (k + y) * xArrSize + newI + x;
						for(int z = 0; z < color_channels; z++)
							if(image[pixel + z] > colorTolerance[z]) {
								counter++;
								stop = true;
								break;
							}
					}
				}
			}
		results[i] = counter;
	};

	cout << endl << "starting Box-Dimension analysis" << endl;

	vector<thread> threads{};
	for(int i = 0; i < probes; i++) 
		threads.emplace_back(boxMethod2, pow(2, i), i); //multithreading for better performance

	for(auto& thread : threads) thread.join(); //join threads after calculation
	ranges::reverse(results); //reverse order of results

	for(uint32_t i = 0; i < results.size(); i ++)
		cout << "magnification x" << pow(2, i) << " hit: " << results[i] << endl;


	double sum = 0;
	for(int i = 1; i < results.size(); i++) 
		sum += log2(static_cast<double>(results[i]) / results[i - 1]); //calculating boxcounting-dimension for every part

	sum /= static_cast<double>(results.size() - 1); //calculating mean boxcounting-dimension

	cout << "estimated fractal dimension: " << sum << " with " << results.size() << " measurements" << endl;
}

int main() {
	cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_ERROR);
	std::ofstream out("output.txt");
	std::cout.rdbuf(out.rdbuf());


	pix = new uint8_t[testPlaneSize * testPlaneSize * static_cast<uint32_t>(channels)]{};
	cout << "plane size: " << testPlaneSizeX * testPlaneSizeY << endl;

	auto start = chrono::high_resolution_clock::now();
	cv::Mat image(testPlaneSizeY, testPlaneSizeX, CV_MAKETYPE(CV_8U, channels), pix);


	mandelbrotCalculation(-.6f, -1.1f, 0.5f, 0.f, image);

	//KochCurve kochCurve(KochCurve::Type::TRIANGLE, curveIterations, probes, testPlaneSize, pix);
	//kochCurve.drawCurve();

	//drawSquare(static_cast<int>(testPlaneSizeX * 0.25), static_cast<int>(testPlaneSizeY * 0.25), static_cast<int>(testPlaneSizeY * 0.5), image);
	boxAlgorithm(image.data, channels, testProbes);

	if(draw) {
		string imageName = "mandelbrot";
		imageName += ".png";
		saveImage(imageName, image);
	}
	if(verifyData) verify(image);
	cout << "finished in " << chrono::duration<float>(chrono::high_resolution_clock::now() - start).count() << "s " << endl;
	out.close();
	return EXIT_SUCCESS;
}
