#include <iostream>

#include "glad/include/glad/glad.h"
#include "SDL.h"
#include "SDL_opengl.h"
#include "glm/vec2.hpp"

#include "RTRRTStar.hpp"
#include "utils.hpp"

static float scrWidth = 300;
static float scrHeight = 300;
static bool fullscreen = false;

static SDL_Window* window;
static SDL_GLContext context;

static RTRRTStar* rrt;
static glm::vec2 top_left;
static glm::vec2 bottom_right;
static glm::vec2 top_right;
static glm::vec2 bottom_left;

const GLchar* rainbowFragment =
	"#version 150 core\n"
	"in vec3 Color;"
	"out vec4 outColor;"
	"void main() {"
	"   outColor = vec4(Color, 1.0);"
	"}";

const GLchar* rainbowVertex =
	"#version 150 core\n"
	"in vec2 position;"
	"in vec3 inColor;"
	"out vec3 Color;"
	"void main() {"
	"   Color = inColor;"
	"   gl_Position = vec4(position, 0.0, 1.0);"
	"}";

// https://open.gl 

void initialize_sdl_version() {
	// initializes SDL with openGL graphics
	SDL_Init(SDL_INIT_VIDEO);
	SDL_version comp; SDL_version linked;
	// gets the current version of SDL
	SDL_GetVersion(&comp);  SDL_GetVersion(&linked);
	printf("\nCompiled against SDL version %d.%d.%d\n", comp.major, comp.minor, comp.patch);
	printf("Linked SDL version %d.%d.%d\n", linked.major, linked.minor, linked.patch);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
}

void init_window() {
	// creates window with:
	//  name, offsetx, offsety, width, height, flags

	/*
		Flags include:
			SDL_WINDOW_FULLSCREEN
			SDL_WINDOW_RESIZABLE
				-> recalculate aspect ratio
			SDL_WINDOW_FULLSCREEN_DESKTOP
				-> windowed borderless
				-> pass 0 for height and width
	*/
	window = SDL_CreateWindow(
		"Final Project: RT-RRT*", // name
		300, 300, // offsetx, offsety
		scrWidth, scrHeight, // width and height of screen
		SDL_WINDOW_OPENGL // flags
	);

	if (!window) {
		printf("Could not create window: %s\n", SDL_GetError());
		abort();
	}
}

void drawCircle(float radius, glm::vec2& loc, int segments) {
	/*if (segments < 4) {
		printf("Tried to create a triangle instead of a circle lol");
		abort();
	}



	for (int i = 0; i < segments; i++) {

	}*/
}

void setup() {
	// initialize anything needed here, RRT, agents, etc...
	
	// initialize RRT things --------------------------------
	std::vector<std::pair<int, GLuint>> vba_pairs;

	glm::vec2 init_pos(0.f, 0.f);
	glm::vec2 init_goal(scrWidth, scrHeight);
	rrt = new RTRRTStar(
		init_pos, init_goal
	);

	top_left.x = -scrWidth/2 + 10.f;
	top_left.y = scrHeight/2 - 10.f;

	bottom_right.x = (scrWidth/2) - 10.f;
	bottom_right.y = -(scrHeight/2) + 10.f;

	bottom_left.x = -(scrWidth / 2) + 10.f;
	bottom_left.y = -(scrHeight / 2) + 10.f;

	top_right.x = (scrWidth / 2) - 10.f;
	top_right.y = (scrHeight / 2) - 10.f;

	// ------------------------------------------------------

	GLuint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	GLuint vbo;
	glGenBuffers(1, &vbo);

	GLfloat vertices[] = {
		top_left.x / (scrWidth / 2), top_left.y / (scrHeight / 2), 0.f,0.f,0.f, // vertex 1 at top left
		top_right.x / (scrWidth / 2), top_right.y / (scrHeight / 2), 0.f,0.f,0.f, // vertex 2 at top right
		bottom_right.x / (scrWidth / 2), bottom_right.y / (scrHeight / 2), 0.f,0.f,0.f, // vertex 3 at bottom right
		bottom_left.x / (scrWidth / 2), bottom_left.y / (scrHeight / 2), 0.f,0.f,0.f // vertex 4 at bottom left
	};

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(
		GL_ARRAY_BUFFER,
		sizeof(vertices),
		vertices,
		GL_STATIC_DRAW // static if not changing much
	);

	GLuint ebo;
	glGenBuffers(1, &ebo);

	GLuint elements[] = {
		0, 1, 1, 2,
		2, 3, 3, 0
	};
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
	glBufferData(
		GL_ELEMENT_ARRAY_BUFFER,
		sizeof(elements),
		elements,
		GL_STATIC_DRAW
	);

	// Setup shaders and vertices for bounds ----------------
	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	loadShader(vertexShader, rainbowVertex);
	GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	loadShader(fragmentShader, rainbowFragment);

	GLuint shaderProgram = glCreateProgram();
	glAttachShader(shaderProgram, vertexShader);
	glAttachShader(shaderProgram, fragmentShader);
	glBindFragDataLocation(shaderProgram, 0, "outColor");
	glLinkProgram(shaderProgram);
	glUseProgram(shaderProgram);

	GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
	glEnableVertexAttribArray(posAttrib);
	glVertexAttribPointer(
		posAttrib, // attribute
		2, GL_FLOAT, // vals per attrib, type
		GL_FALSE, // isNormalized
		5 * sizeof(GL_FLOAT), // stride
		0 // offset
	);

	GLint colAttrib = glGetAttribLocation(shaderProgram, "inColor");
	glEnableVertexAttribArray(colAttrib);
	glVertexAttribPointer(
		colAttrib,
		3, GL_FLOAT,
		GL_FALSE,
		5 * sizeof(GL_FLOAT),
		(void*)(2 * sizeof(GL_FLOAT))
	);

	// ------------------------------------------------------

	// this is the main gameloop
	// it updates the screen and also listens for events
	SDL_Event windowEvent;
	bool quit = false;
	while (!quit) {
		while (SDL_PollEvent(&windowEvent)) {
			if (windowEvent.type == SDL_QUIT) quit = true; // exit game loop
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_ESCAPE)
				quit = true; // exit game loop
			if (windowEvent.type == SDL_KEYUP && windowEvent.key.keysym.sym == SDLK_f) {
				fullscreen = !fullscreen;
				SDL_SetWindowFullscreen(window, fullscreen ? SDL_WINDOW_FULLSCREEN : 0);
			}
		}

		glClearColor(0.2f, 0.5f, 0.8f, 1.0f); // clears screen to blue
		glClear(GL_COLOR_BUFFER_BIT);

		// do drawing of agents and lines here
		
		// first draw the bounds

		glDrawElements(GL_LINES, 8, GL_UNSIGNED_INT, 0);

		SDL_GL_SwapWindow(window); // double buffering
	}

	glDeleteProgram(shaderProgram);
	glDeleteShader(fragmentShader);
	glDeleteShader(vertexShader);
	glDeleteBuffers(1, &vbo);
	glDeleteVertexArrays(1, &vao);
	delete rrt;
}

int main(int argc, char** argv) {
	initialize_sdl_version();
	init_window();
	context = SDL_GL_CreateContext(window);
	// print version but this time using glad and ensure all pointers are loaded
	if (gladLoadGLLoader(SDL_GL_GetProcAddress)) {
		printf("OpenGL loaded\n");
		printf("Vendor: %s\n", glGetString(GL_VENDOR));
		printf("Renderer: %s\n", glGetString(GL_RENDERER));
		printf("Version: %s\n", glGetString(GL_VERSION));
	}
	else {
		printf("ERROR: Failed to initialize OpenGL context.\n");
		abort();
	}

	setup();

	// cleanup SDL and OpenGL contexts
	SDL_GL_DeleteContext(context);
	SDL_Quit();

	return 0;
}