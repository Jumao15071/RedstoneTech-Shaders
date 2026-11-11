
import os  
import re  

regex01 = re.compile(r'\/\/.*|\/\*[\s\S]*?\*\/')  #单行或多行注释
regex02 = re.compile(r'(^[ \t]+$|[ \t]+$)')  #行尾空格
regex03 = re.compile(r'(?<=\n)(\s+)(?=[^\s])')  #行首空格或空行

regex1 = re.compile(r'(?<=[(){}<>=+\-*/|&?:;,])\s+|\s+(?=[(){}<>=+\-*/|&?:;,])')  #符号两侧空行
regex2 = re.compile(r'([a-zA-Z]+)(?=_[0-9]+)')  #临时变量名
regex3 = re.compile(r'(?<=\d\.\d{7})\d+')  #小数点后7位
regex4 = re.compile(r'(?<=\d\.\d\d)(0+)(?=[^\d])')  #小数末尾零
regex5 = re.compile(r'--')  #双负号
regex6 = re.compile(r'(?<=.)#')  #宏定义修复

regex_j1 = re.compile(r'\"DepthOnly(\"|Opaque\")(,\s*|\s*)')  
regex_j2 = re.compile(r',(?=\s*[}\]])')  

regex_es300 = re.compile(r'#version 300 es\s*')  
replace_es300 = '#version 300 es \n'  

total_count = 0

def strip_1(content):
    content, t1 = regex01.subn('', content)  
    content, t2 = regex02.subn('', content)  
    content, t3 = regex03.subn('', content)  
    t = t1 + t2 + t3
    return content, t
    
def strip_2(content):
    content, t1 = regex1.subn('', content)  
    content, t2 = regex2.subn('', content)  
    content, t3 = regex3.subn('', content)  
    content, t4 = regex4.subn('', content)  
    content, t5 = regex5.subn('- -', content)  
    content, t6 = regex6.subn('\n#', content)  
    t = t1 + t2 + t3 + t4 + t5 + t6
    return content, t

def strip_j(content):
    content, count_j = regex_j1.subn('', content)  
    if count_j > 0:  
        print('DepthOnly has removed')  
    content = regex_j2.sub('', content)  
    return content 

def main(file):
    global total_count
    if file.endswith('.glsl'):  
        file_path = os.path.join(root, file)  
        with open(file_path, 'r', encoding='utf-8') as f:  
            content = f.read()  
        content, t1 = strip_1(content)
        content, t2 = strip_2(content)
        if t1 + t2 > 0:
            total_count += 1
            with open(file_path, 'w', encoding='utf-8') as f:  
                f.write(content) 
            print(f"Processed: {t1 + t2}")
    
    # if file.endswith('.json'):  
    #     file_path = os.path.join(root, file)  
    #     with open(file_path, 'r', encoding='utf-8') as f:  
    #         content = f.read()  
    #     # content = strip_j(content)
    #     with open(file_path, 'w', encoding='utf-8') as f:  
    #         f.write(content) 
    

if __name__ == "__main__":
    directory= 'src'  
    for root, dirs, files in os.walk(directory):  
        for file in files:  
            main(file)
    print(f"All done. {total_count} files processed.")




