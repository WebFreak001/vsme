/*
    Copyright © 2019 Clipsey & Anego Studios

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module viewports.modelview;
import gtk.GLArea;
import gdk.GLContext;
import gtk.ApplicationWindow;
import gl.shader;
import components.glviewport;
import bindbc.opengl;
import gl.camera;
import math;
import config;
import assets;
import scene.scene;

class ModelingViewport : EditorViewport {
public:
    bool isMovingCamera;

    Vector2 referencePosition;
    float refRotationX;
    float refRotationY;

    Camera camera;
    import std.stdio : writeln;

    this(ApplicationWindow window) {
        super(window);
        this.setSizeRequest(1024, 768);
    }

    override void init() {
        BASIC_SHADER = loadShaderOptimal!("basic");
        LINE_SHADER = loadShaderOptimal!("line");

        camera = new Camera(this);
        camera.changeFocus(Vector3(0, 0, 0), 50);
        camera.rotationX = mathf.radians(25f);
        camera.rotationY = mathf.radians(90f);

        SCENE = new Scene(true);
        // Refocus the scene on the first child (which is a cube)
        // We do this so that the program doesn't get confused about what to focus on in the transform widget.
        SCENE.changeFocus(SCENE.rootNode.children[0]);
    }
    
    override bool onKeyPressEvent(GdkEventKey* key) {
        import gdk.Keysyms;
        if (key.keyval == Keysyms.GDK_Q) {

            if (CONFIG.camera.perspective) {
                this.projectionSwitch.ortho.setActive(true);
            } else {
                this.projectionSwitch.persp.setActive(true);
            }
        }
        if (key.keyval == Keysyms.GDK_F12) {
            CONFIG.ui.window.fullscreen = !CONFIG.ui.window.fullscreen;
            if (CONFIG.ui.window.fullscreen) {
                window.fullscreen();
            } else {
                window.unfullscreen();
            }
        }
        return false;
    }

    override bool onButtonPressEvent(GdkEventButton* button) {
        if (!isMovingCamera && button.button == 2) {
            referencePosition = Vector2(button.x, button.y);
            refRotationX = camera.rotationX;
            refRotationY = camera.rotationY;
            isMovingCamera = true;
            return true;
        }
        return false;
    }

    override bool onScrollEvent(GdkEventScroll* scroll) {
        camera.distance += scroll.deltaY;
        return false;
    }

    override bool onButtonReleaseEvent(GdkEventButton* button) {
        if (button.button == 2) {
            isMovingCamera = false;
        }
        return false;
    }

    override bool onMotionNotifyEvent(GdkEventMotion* motion) {
        if (isMovingCamera) {
            camera.rotationX = refRotationX;
            camera.rotationY = refRotationY;

            if (!CONFIG.camera.invertX) camera.rotationX  -= mathf.radians((referencePosition.y-motion.y)/CONFIG.camera.cameraSlowFactor);
            else camera.rotationX += mathf.radians((referencePosition.y-motion.y)/CONFIG.camera.cameraSlowFactor);

            if (!CONFIG.camera.invertY) camera.rotationY -= mathf.radians((referencePosition.x-motion.x)/CONFIG.camera.cameraSlowFactor);
            else camera.rotationY += mathf.radians((referencePosition.x-motion.x)/CONFIG.camera.cameraSlowFactor);
            return true;
        }
        return false;
    }

    override void update() {
        if (SCENE !is null) {
            if (SCENE.hasFocusChanged) {
                SCENE.setCameraFocalPoint(camera);
            }
        }
        // camera.position = Vector3(20, 21, 20);
        // camera.lookAt(Vector3(0, 0, 0));
        camera.transformView();
        camera.update();
    }

    override bool draw(GLContext context, GLArea area) {
        if (SCENE !is null) {
            if (SCENE.sceneReloaded()) {
                SCENE.setContext(this.viewport);
                nodeTree.updateTree();
            }
            SCENE.update();
            SCENE.render(camera);
        }
        return true;
    }
}

ShaderProgram loadShaderOptimal(string name)() {
    version(RELEASE) {
        return ShaderProgram.fromFilesCompileTime!(name~".vert", name~".frag")();
    } else {
        Shader vert = Shader.loadFromFile("shaders/"~name~".vert");
        Shader frag = Shader.loadFromFile("shaders/"~name~".frag");
        return ShaderProgram(vert, frag);
    }
}