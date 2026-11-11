cd "C:\mc_tool\spv-opt-01281706"
laz-unpack.bat
spv-opt-steps.bat
python regex-replace.py
python glsl_reduce.py
laz-repack.bat

1. build your shaders using ESSL_310, put mateiral.bin files under this directory.

2. lazurite unpack ( laz-unpack.bat )

3. optimize shaders using spirv-cross ( spv-opt-steps.bat )

4. fix inout bindings ( python regex-replace.py )
1
5. (optional) minify glsl code, remove spaces to reduce size ( python glsl_reduce.py )

6. lazurite repack ( laz-repack.bat )



Note: the executable programs in this tool were from VulkanSDK ( https://sdk.lunarg.com/sdk/download/1.3.296.0/windows/VulkanSDK-1.3.296.0-Installer.exe )
