/*
    Copyright © 2019 Clipsey & Anego Studios

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module scene.nodes.root;
import scene.node;
import math;

/++
    The root node of a scene
+/
class RootNode : Node {
public:
    this() {
        super(NodeType.RootNode);
        this.name = "Scene";
        this.startPosition = Vector3(0, 0, 0);
        this.endPosition = Vector3(0, 0, 0);
    }

    override Matrix4x4 transform() {
        return Matrix4x4.identity;
    }

    override void updateBuffer() {
        // There's no buffer in the root node, though make sure that the user doesn't move the root.
        this.startPosition = Vector3(0, 0, 0);
        this.endPosition = Vector3(0, 0, 0);
        this.origin = Vector3(0, 0, 0);
        this.rotation = Vector3(0, 0, 0);
    }

    override void render(Camera camera) {
        foreach(child; children) {
            child.render(camera);
        }
    }
}