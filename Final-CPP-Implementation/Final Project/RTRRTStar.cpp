#include "RTRRTStar.hpp"

RTRRTStar::RTRRTStar(glm::vec2& init_root, glm::vec2& init_goal) {
	this->root = init_root;
	this->goal = init_goal;
}

RTRRTStar::~RTRRTStar() {}