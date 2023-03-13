#include "KochCurve.hpp"

#include <thread>
#include <glm/glm.hpp>
#include <glm/gtc/constants.hpp>
#include <vector>
#include <iostream>
using namespace std;
using namespace std::chrono;
void KochCurve::pixLine(float x1, float y1, const float x2, const float y2) {
	const float xDist = x2 - x1, yDist = y2 - y1;
	float iters = abs(xDist) > abs(yDist) ? xDist : yDist;
	iters = abs(iters);
	for(uint32_t i = 0; i < iters; i++) {
		pix[static_cast<uint32_t>(y1) * testPlaneSize + static_cast<uint32_t>(x1)] = 255;
		x1 += xDist / iters;
		y1 += yDist / iters;
	}
	pix[static_cast<uint32_t>(y2) * testPlaneSize + static_cast<uint32_t>(x2)] = 255;
	lineCounter++;
}
void KochCurve::triangularKochCurve(const float x1, const float y1, const float size, const float angle, const uint32_t n) {
	if(n > 0) {
		const float newSize = size / 3;
		triangularKochCurve(x1, y1, newSize, angle, n - 1);
		triangularKochCurve(x1 + newSize * cos(angle), y1 + newSize * sin(angle), newSize, angle - glm::pi<float>() / 3, n - 1);
		triangularKochCurve(x1 + newSize * (2 * cos(angle) + cos(angle - glm::pi<float>() / 1.5f)),
			y1 + newSize * (2.f * sin(angle) + sin(angle - glm::pi<float>() / 1.5f)),
			newSize,
			angle + glm::pi<float>() / 3,
			n - 1);
		triangularKochCurve(x1 + 2 * newSize * cos(angle), y1 + 2 * newSize * sin(angle), newSize, angle, n - 1);
	}
	if(n == 0) pixLine(x1, y1, x1 + cos(angle) * size, y1 + sin(angle) * size);
}
void KochCurve::squareKochCurve(float x1, float y1, const float size, float angle, const int n) {
	if(n > 0) {
		const float newSize = size / 4;

		const float sinu = sin(angle) * newSize, cosi = cos(angle) * newSize;
		const float sinuq = sin(angle + glm::pi<float>() / 2) * newSize;
		const float cosiq = cos(angle + glm::pi<float>() / 2) * newSize;

		squareKochCurve(x1, y1, newSize, angle, n - 1);
		x1 += cosi;
		y1 += sinu;
		squareKochCurve(x1, y1, newSize, angle - glm::pi<float>() / 2, n - 1);
		x1 -= cosiq;
		y1 -= sinuq;
		squareKochCurve(x1, y1, newSize, angle, n - 1);
		x1 += cosi;
		y1 += sinu;
		squareKochCurve(x1, y1, newSize, angle + glm::pi<float>() / 2, n - 1);
		x1 += cosiq;
		y1 += sinuq;
		squareKochCurve(x1, y1, newSize, angle + glm::pi<float>() / 2, n - 1);
		x1 += cosiq;
		y1 += sinuq;
		squareKochCurve(x1, y1, newSize, angle, n - 1);
		x1 += cosi;
		y1 += sinu;
		squareKochCurve(x1, y1, newSize, angle - glm::pi<float>() / 2, n - 1);
		x1 -= cosiq;
		y1 -= sinuq;
		squareKochCurve(x1, y1, newSize, angle, n - 1);
	}
	else pixLine(x1, y1, x1 + cos(angle) * size, y1 + sin(angle) * size);
}
void KochCurve::printLineCounter() {
	cout << "curve drawing started" << endl;
	long maxIterations;
	switch(type) {
		case TRIANGLE:
			maxIterations = pow(4, iterations);
			break;
		case RECT:
			maxIterations = pow(8, iterations);
			break;
		default:
			maxIterations = 0;
			break;
	}

	auto start = high_resolution_clock::now();
	duration<float> duration{};
	int sec = 2;
	while(lineCounter < maxIterations) {
		duration = high_resolution_clock::now() - start;
		if(duration.count() > sec) {
			cout << static_cast<int>(duration.count()) << "s\t" << static_cast<int>(static_cast<float>(lineCounter) / static_cast
				<float>(maxIterations) * 100) << "% finished\tlines drawn: " << lineCounter << "/" << maxIterations << "\r";
			sec += 2;
		}
	}
	duration = high_resolution_clock::now() - start;
	cout << endl << "curve drawn with " << static_cast<long>(maxIterations) << " lines in " << duration.count()
		<< "s" << endl << endl;
}
void KochCurve::drawCurve() {
	float size = static_cast<float>(testPlaneSize - 200);
	float x = (static_cast<float>(testPlaneSize) - size) / 2;
	float y = 0;
	switch(type) {
		case TRIANGLE:
			y = static_cast<float>(testPlaneSize) / 1.5f;
			break;
		case RECT:
			y = static_cast<float>(testPlaneSize) / 2.f;
			break;
	}

	thread countThread(&KochCurve::printLineCounter, this);
	std::vector<thread> curveThreads{};
	float newSize;
	switch(type) {
		case TRIANGLE:
			newSize = size / 3;
			curveThreads.emplace_back(&KochCurve::triangularKochCurve, this, x, y, newSize, 0, iterations - 1);
			curveThreads.emplace_back(&KochCurve::triangularKochCurve, this, x + newSize, y, newSize, 0 - glm::pi<float>() / 3, iterations - 1);
			curveThreads.emplace_back(&KochCurve::triangularKochCurve,
				this,
				x + newSize * (2 + cos(-glm::pi<float>() / 1.5f)),
				y + newSize * sin(-glm::pi<float>() / 1.5f),
				newSize,
				glm::pi<float>() / 3,
				iterations - 1);
			curveThreads.emplace_back(&KochCurve::triangularKochCurve, this, x + 2 * newSize, y, newSize, 0, iterations - 1);
			break;
		case RECT:
			newSize = size / 4;

			squareKochCurve(x, y, newSize, 0, iterations - 1);
			x += newSize;
			squareKochCurve(x, y, newSize, -glm::pi<float>() / 2, iterations - 1);
			y -= newSize;
			squareKochCurve(x, y, newSize, 0, iterations - 1);
			x += newSize;
			squareKochCurve(x, y, newSize, glm::pi<float>() / 2, iterations - 1);
			y += newSize;
			squareKochCurve(x, y, newSize, glm::pi<float>() / 2, iterations - 1);
			y += newSize;
			squareKochCurve(x, y, newSize, 0, iterations - 1);
			x += newSize;
			squareKochCurve(x, y, newSize, - glm::pi<float>() / 2, iterations - 1);
			y -= newSize;
			squareKochCurve(x, y, newSize, 0, iterations - 1);
			break;
	}

	for(auto& thread : curveThreads) thread.join();

	lineCounter = pow(4, iterations);
	countThread.join();
}
