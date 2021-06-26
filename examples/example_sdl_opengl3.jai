// Dear ImGui: standalone example application for SDL2 + OpenGL
// (SDL is a cross-platform general purpose library for handling windows, inputs, OpenGL/Vulkan/Metal graphics context creation, etc.)
// (GL3W is a helper library to access OpenGL functions since there is no standard header to access modern OpenGL functions easily. Alternatives are GLEW, Glad, etc.)
// If you are new to Dear ImGui, read documentation from the docs/ folder + read the top of imgui.cpp.
// Read online: https://github.com/ocornut/imgui/tree/master/docs

// ImGui :: #import "imgui"(LINK_STATIC=true);
#load "imgui_impl_sdl.jai"; // SDL platform backend
#load "imgui_impl_opengl3.jai"; // OpenGL renderer backend
#import "Basic";
#import "SDL";
#import "GL";

f : float = 0.0;
counter : s32 = 0;

ctx: *ImGui.Context;
_imgui_alloc_context: Context;
c_alloc :: (sz: u64, userdata: *void) -> *void #c_call { push_context << cast(*Context)userdata { return alloc(cast(s64)sz); } }
c_free :: (ptr: *void, userdata: *void) -> void #c_call { push_context << cast(*Context)userdata { free(ptr); } }

ImGui_Impl_CreateContext :: ($set_default_allocators := true) {
    #if set_default_allocators {
        _imgui_alloc_context = context;
        ImGui.SetAllocatorFunctions(c_alloc, c_free, *_imgui_alloc_context);
    }

    ctx = ImGui.CreateContext();
    io := ImGui.GetIO();
    io.ConfigFlags_ |= .DockingEnable;
}

main :: () {
    // Setup SDL
    // (Some versions of SDL before <2.0.10 appears to have performance/stalling issues on a minority of Windows systems,
    // depending on whether SDL_INIT_GAMECONTROLLER is enabled or disabled.. updating to latest version of SDL is recommended!)
    if SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0 {
        print("Error: %\n", to_string(SDL_GetError()));
        return;
    }

    // Decide GL+GLSL versions
    // GL 3.0 + GLSL 130
    glsl_version :: "#version 130";
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);

    // Create window with graphics context
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
    SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);
    window_flags : SDL_WindowFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI;
    window := SDL_CreateWindow("Dear ImGui SDL2+OpenGL3 example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, window_flags);
    gl_context := SDL_GL_CreateContext(window);

    if !gl_context {
        print("Could not create OpenGL context: %\n", to_string(SDL_GetError()));
    }

    SDL_GL_MakeCurrent(window, gl_context);
    SDL_GL_SetSwapInterval(1); // Enable vsync

    // Initialize OpenGL loader
    gl_load(*gl, SDL_GL_GetProcAddress);

    // Setup Dear ImGui context
    // IMGUI_CHECKVERSION();
    ImGui_Impl_CreateContext();
    assert(ctx != null, "must call create context");
    ImGui.SetCurrentContext(ctx);

    io := ImGui.GetIO();
    // io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;       // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls
    // io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;           // Enable Docking
    // io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;         // Enable Multi-Viewport / Platform Windows
    //io.ConfigViewportsNoAutoMerge = true;
    //io.ConfigViewportsNoTaskBarIcon = true;

    // Setup Dear ImGui style
    ImGui.StyleColorsDark();
    //ImGui::StyleColorsClassic();

    // When viewports are enabled we tweak WindowRounding/WindowBg so platform windows can look identical to regular ones.
    // style := ImGui.GetStyle();
    // if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
    // {
    //     style.WindowRounding = 0.0f;
    //     style.Colors[ImGuiCol_WindowBg].w = 1.0f;
    // }

    // Setup Platform/Renderer backends
    ImGui_ImplSDL2_InitForOpenGL(window, gl_context);
    ImGui_ImplOpenGL3_Init(glsl_version);

    // Load Fonts
    // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use ImGui::PushFont()/PopFont() to select them.
    // - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
    // - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
    // - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
    // - Read 'docs/FONTS.md' for more instructions and details.
    // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
    //io.Fonts->AddFontDefault();
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0f);
    //ImFont* font = io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());
    //IM_ASSERT(font != NULL);

    // Our state
    show_demo_window := true;
    show_another_window := false;
    clear_color := ImGui.make_ImVec4(0.45, 0.55, 0.60, 1.00);

    // Main loop
    done := false;
    while !done {
        // Poll and handle events (inputs, window resize, etc.)
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        event : SDL_Event ;
        while SDL_PollEvent(*event) {
            ImGui_ImplSDL2_ProcessEvent(*event);
            if event.type == {
                case .SDL_QUIT;
                    done = true;
                case .SDL_WINDOWEVENT; 
                    if event.window.event == .SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window) {
                        done = true;
                    }
            }
        }

        // Start the Dear ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplSDL2_NewFrame(window);
        ImGui.NewFrame();

        // 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if show_demo_window ImGui.ShowDemoWindow(*show_demo_window);

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        {

            ImGui.Begin("Hello, world!");

            ImGui.Text("This is some useful text.");
            ImGui.Checkbox("Demo Window", *show_demo_window);
            ImGui.Checkbox("Another Window", *show_another_window);

            ImGui.SliderFloat("float", *f, 0.0, 1.0);
            ImGui.ColorEdit3("clear color", xx *clear_color);

            if (ImGui.Button("Button")) counter += 1;
            ImGui.SameLine();
            ImGui.Text("counter = %d", counter);

            ImGui.Text("Application average % ms/frame (% FPS)", 1000.0 / ImGui.GetIO().Framerate, ImGui.GetIO().Framerate);
            ImGui.End();
        }

        // 3. Show another simple window.
        if show_another_window {
            ImGui.Begin("Another Window", *show_another_window);
            ImGui.Text("Hello from another window!");
            if ImGui.Button("Close Me") show_another_window = false;
            ImGui.End();
        }

        // Rendering
        ImGui.Render();
        glViewport(0, 0, xx io.DisplaySize.x, xx io.DisplaySize.y);
        glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui.GetDrawData());

        // Update and Render additional Platform Windows
        // (Platform functions may change the current OpenGL context, so we save/restore it to make it easier to paste this code elsewhere.
        //  For this specific demo app we could also call SDL_GL_MakeCurrent(window, gl_context) directly)
        if io.ConfigFlags_ & .ViewportsEnable {
            backup_current_window := SDL_GL_GetCurrentWindow();
            backup_current_context := SDL_GL_GetCurrentContext();
            ImGui.UpdatePlatformWindows();
            ImGui.RenderPlatformWindowsDefault();
            SDL_GL_MakeCurrent(backup_current_window, backup_current_context);
        }

        SDL_GL_SwapWindow(window);
    }

    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui.DestroyContext();

    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}