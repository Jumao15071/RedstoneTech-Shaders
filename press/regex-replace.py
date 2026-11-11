
import os  
import re  

regex_1 = re.compile(r'layout\(location\s?\=\s?\d+\)\s?')
replace_1 = ''

regex_2 = re.compile(r'bgfx_FragData\[32\]')
replace_2 = 'bgfx_FragData[gl_MaxDrawBuffers]'

total_count = 0

def main(file):
    global total_count
    if file.endswith('.glsl'):  
        file_path = os.path.join(root, file)  
        with open(file_path, 'r', encoding='utf-8') as f:  
            content = f.read() 
        
        content, t1 = regex_1.subn(replace_1, content)
        content, t2 = regex_2.subn(replace_2, content)
        
        if t1 + t2 > 0:
            total_count += 1
            with open(file_path, 'w', encoding='utf-8') as f:  
                f.write(content) 

if __name__ == "__main__":
    directory= 'src'  
    for root, dirs, files in os.walk(directory):  
        for file in files:  
            main(file)
    print(f"Completed. {total_count} files changed.")




