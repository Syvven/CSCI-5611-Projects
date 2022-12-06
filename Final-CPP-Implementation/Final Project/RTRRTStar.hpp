#ifndef RTRRTSTAR_H_
#define RTRRTSTAR_H_

#include <iostream>
#include <stdlib.h>
#include <vector>

#include "glad/include/glad/glad.h"
#include "SDL.h"
#include "SDL_opengl.h"
#include "glm/vec2.hpp"

class RTRRTStar {
public:
	RTRRTStar(glm::vec2& init_root, glm::vec2& init_goal);
	~RTRRTStar();

private:
	glm::vec2 root;
	glm::vec2 goal;
	std::vector<glm::vec2> obstacles;
};

#endif