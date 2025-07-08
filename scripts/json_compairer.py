#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Set, Any
from datetime import datetime

def flatten_json(data: Dict[str, Any], parent_key: str = '', separator: str = '.') -> Dict[str, Any]:
    """
    将嵌套的JSON对象扁平化为点分隔的键值对
    
    Args:
        data: 要扁平化的JSON数据
        parent_key: 父级键名
        separator: 键名分隔符
    
    Returns:
        扁平化后的字典
    """
    items = []
    for key, value in data.items():
        new_key = f"{parent_key}{separator}{key}" if parent_key else key
        if isinstance(value, dict):
            items.extend(flatten_json(value, new_key, separator).items())
        else:
            items.append((new_key, value))
    return dict(items)

def unflatten_json(data: Dict[str, Any], separator: str = '.') -> Dict[str, Any]:
    """
    将扁平化的JSON对象还原为嵌套结构
    
    Args:
        data: 扁平化的JSON数据
        separator: 键名分隔符
    
    Returns:
        嵌套的JSON对象
    """
    result = {}
    for key, value in data.items():
        parts = key.split(separator)
        current = result
        for part in parts[:-1]:
            if part not in current:
                current[part] = {}
            current = current[part]
        current[parts[-1]] = value
    return result

def load_json_file(file_path: str) -> Dict[str, Any]:
    """
    加载JSON文件
    
    Args:
        file_path: JSON文件路径
    
    Returns:
        JSON数据字典
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"❌ 文件不存在: {file_path}")
        return {}
    except json.JSONDecodeError as e:
        print(f"❌ JSON解析错误 {file_path}: {e}")
        return {}
    except Exception as e:
        print(f"❌ 读取文件错误 {file_path}: {e}")
        return {}

def save_json_file(file_path: str, data: Dict[str, Any]) -> bool:
    """
    保存JSON文件
    
    Args:
        file_path: JSON文件路径
        data: 要保存的数据
    
    Returns:
        是否保存成功
    """
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"❌ 保存文件错误 {file_path}: {e}")
        return False

def get_all_json_files(translations_dir: str) -> List[str]:
    """
    获取翻译目录下的所有JSON文件
    
    Args:
        translations_dir: 翻译文件目录
    
    Returns:
        JSON文件路径列表
    """
    json_files = []
    if os.path.exists(translations_dir):
        for file in os.listdir(translations_dir):
            if file.endswith('.json'):
                json_files.append(os.path.join(translations_dir, file))
    return sorted(json_files)

def find_reference_value(key: str, all_data: Dict[str, Dict[str, Any]]) -> str:
    """
    为缺失的键找到参考值
    
    Args:
        key: 缺失的键
        all_data: 所有翻译数据
    
    Returns:
        参考值或占位符
    """
    # 首先尝试从其他文件中找到这个键的值
    for filename, data in all_data.items():
        flattened = flatten_json(data)
        if key in flattened:
            return flattened[key]
    
    # 如果没找到，生成一个占位符
    key_parts = key.split('.')
    last_part = key_parts[-1]
    
    # 根据键名生成合理的占位符
    placeholders = {
        'title': 'Title',
        'name': 'Name',
        'description': 'Description',
        'hint': 'Hint',
        'label': 'Label',
        'placeholder': 'Placeholder',
        'button': 'Button',
        'confirm': 'Confirm',
        'cancel': 'Cancel',
        'yes': 'Yes',
        'no': 'No',
        'loading': 'Loading...',
        'error': 'Error',
        'success': 'Success',
        'failed': 'Failed',
        'warning': 'Warning',
    }
    
    for placeholder_key, placeholder_value in placeholders.items():
        if placeholder_key in last_part.lower():
            return placeholder_value
    
    # 默认占位符
    return f"TODO: {last_part.replace('_', ' ').title()}"

def generate_missing_keys_report(translations_dir: str, output_file: str = None):
    """
    生成缺失键的报告
    
    Args:
        translations_dir: 翻译文件目录
        output_file: 输出文件路径
    """
    json_files = get_all_json_files(translations_dir)
    
    if not json_files:
        print(f"❌ 在目录 {translations_dir} 中没有找到JSON文件")
        return
    
    # 加载所有JSON文件
    all_data = {}
    all_keys = {}
    
    for file_path in json_files:
        filename = os.path.basename(file_path)
        data = load_json_file(file_path)
        if data:
            all_data[filename] = data
            all_keys[filename] = set(flatten_json(data).keys())
    
    if not all_data:
        print("❌ 没有成功加载任何JSON文件")
        return
    
    # 找出所有键的并集
    all_possible_keys = set()
    for keys in all_keys.values():
        all_possible_keys.update(keys)
    
    # 生成报告
    report = []
    report.append(f"# 翻译文件缺失键报告")
    report.append(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append(f"翻译文件目录: {translations_dir}")
    report.append(f"总键数: {len(all_possible_keys)}")
    report.append("")
    
    # 统计信息
    report.append("## 统计信息")
    report.append("| 文件名 | 键数量 | 缺失键数量 |")
    report.append("|--------|--------|------------|")
    
    for filename, keys in all_keys.items():
        missing_count = len(all_possible_keys - keys)
        report.append(f"| {filename} | {len(keys)} | {missing_count} |")
    
    report.append("")
    
    # 详细缺失信息
    report.append("## 缺失键详情")
    
    for filename, keys in all_keys.items():
        missing_keys = all_possible_keys - keys
        if missing_keys:
            report.append(f"### {filename}")
            report.append(f"缺失 {len(missing_keys)} 个键:")
            for key in sorted(missing_keys):
                report.append(f"- `{key}`")
            report.append("")
    
    # 输出报告
    report_content = "\n".join(report)
    
    if output_file:
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(report_content)
            print(f"✅ 报告已保存到: {output_file}")
        except Exception as e:
            print(f"❌ 保存报告失败: {e}")
    else:
        print(report_content)

def fix_missing_keys(translations_dir: str, dry_run: bool = True):
    """
    修复缺失的键
    
    Args:
        translations_dir: 翻译文件目录
        dry_run: 是否为试运行模式
    """
    json_files = get_all_json_files(translations_dir)
    
    if not json_files:
        print(f"❌ 在目录 {translations_dir} 中没有找到JSON文件")
        return
    
    # 加载所有JSON文件
    all_data = {}
    all_keys = {}
    
    for file_path in json_files:
        filename = os.path.basename(file_path)
        data = load_json_file(file_path)
        if data:
            all_data[filename] = data
            all_keys[filename] = set(flatten_json(data).keys())
    
    if not all_data:
        print("❌ 没有成功加载任何JSON文件")
        return
    
    # 找出所有键的并集
    all_possible_keys = set()
    for keys in all_keys.values():
        all_possible_keys.update(keys)
    
    # 修复每个文件的缺失键
    for file_path in json_files:
        filename = os.path.basename(file_path)
        if filename not in all_data:
            continue
        
        missing_keys = all_possible_keys - all_keys[filename]
        if not missing_keys:
            print(f"✅ {filename} 无需修复")
            continue
        
        print(f"🔧 {'[试运行] ' if dry_run else ''}修复 {filename} 的 {len(missing_keys)} 个缺失键:")
        
        # 获取当前文件的扁平化数据
        flattened_data = flatten_json(all_data[filename])
        
        # 添加缺失的键
        for key in sorted(missing_keys):
            reference_value = find_reference_value(key, all_data)
            flattened_data[key] = reference_value
            print(f"  + {key} = \"{reference_value}\"")
        
        # 如果不是试运行，保存文件
        if not dry_run:
            # 将扁平化数据还原为嵌套结构
            nested_data = unflatten_json(flattened_data)
            
            # 保存文件
            if save_json_file(file_path, nested_data):
                print(f"  ✅ 已保存 {filename}")
            else:
                print(f"  ❌ 保存 {filename} 失败")
        
        print()

def compare_translation_files(translations_dir: str):
    """
    比较翻译文件，找出缺失的键
    
    Args:
        translations_dir: 翻译文件目录
    """
    json_files = get_all_json_files(translations_dir)
    
    if not json_files:
        print(f"❌ 在目录 {translations_dir} 中没有找到JSON文件")
        return
    
    print(f"🔍 找到 {len(json_files)} 个翻译文件:")
    for file in json_files:
        print(f"  - {os.path.basename(file)}")
    print()
    
    # 加载所有JSON文件
    all_data = {}
    all_keys = {}
    
    for file_path in json_files:
        filename = os.path.basename(file_path)
        data = load_json_file(file_path)
        if data:
            all_data[filename] = data
            all_keys[filename] = set(flatten_json(data).keys())
        else:
            print(f"⚠️  跳过空文件: {filename}")
    
    if not all_data:
        print("❌ 没有成功加载任何JSON文件")
        return
    
    # 找出所有键的并集
    all_possible_keys = set()
    for keys in all_keys.values():
        all_possible_keys.update(keys)
    
    print(f"📊 总共发现 {len(all_possible_keys)} 个唯一键")
    print()
    
    # 检查每个文件缺失的键
    has_missing_keys = False
    
    for filename, keys in all_keys.items():
        missing_keys = all_possible_keys - keys
        if missing_keys:
            has_missing_keys = True
            print(f"❌ {filename} 缺失 {len(missing_keys)} 个键:")
            for key in sorted(missing_keys):
                print(f"  - {key}")
            print()
        else:
            print(f"✅ {filename} 包含所有键")
    
    if not has_missing_keys:
        print("🎉 所有翻译文件都包含相同的键！")
        return
    
    # 显示键统计信息
    print("\n📈 键统计信息:")
    print(f"{'文件名':<20} {'键数量':<10} {'缺失键数量':<12}")
    print("-" * 45)
    
    for filename, keys in all_keys.items():
        missing_count = len(all_possible_keys - keys)
        print(f"{filename:<20} {len(keys):<10} {missing_count:<12}")
    
    # 找出只在某些文件中存在的键
    print("\n🔍 键分布分析:")
    key_distribution = {}
    for key in all_possible_keys:
        files_with_key = [filename for filename, keys in all_keys.items() if key in keys]
        key_distribution[key] = files_with_key
    
    # 找出不在所有文件中的键
    incomplete_keys = {key: files for key, files in key_distribution.items() if len(files) < len(all_keys)}
    
    if incomplete_keys:
        print(f"发现 {len(incomplete_keys)} 个键不在所有文件中:")
        for key, files in sorted(incomplete_keys.items()):
            missing_files = [f for f in all_keys.keys() if f not in files]
            print(f"  {key}")
            print(f"    存在于: {', '.join(files)}")
            print(f"    缺失于: {', '.join(missing_files)}")
            print()
    else:
        print("所有键都在所有文件中存在！")

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='比较翻译文件中的键，找出缺失的键')
    parser.add_argument('translations_dir', nargs='?', 
                       help='翻译文件目录路径 (默认: ../lib/assets/translations)')
    parser.add_argument('--report', '-r', metavar='FILE',
                       help='生成报告并保存到指定文件')
    parser.add_argument('--fix', '-f', action='store_true',
                       help='修复缺失的键')
    parser.add_argument('--dry-run', '-d', action='store_true',
                       help='试运行模式，不实际修改文件')
    
    args = parser.parse_args()
    
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 翻译文件目录路径
    if args.translations_dir:
        translations_dir = args.translations_dir
    else:
        translations_dir = os.path.join(script_dir, '..', 'lib', 'assets', 'translations')
        translations_dir = os.path.normpath(translations_dir)
    
    print(f"🚀 开始比较翻译文件...")
    print(f"📁 翻译文件目录: {translations_dir}")
    print()
    
    if not os.path.exists(translations_dir):
        print(f"❌ 翻译文件目录不存在: {translations_dir}")
        sys.exit(1)
    
    if args.report:
        generate_missing_keys_report(translations_dir, args.report)
    elif args.fix:
        fix_missing_keys(translations_dir, dry_run=args.dry_run)
    else:
        compare_translation_files(translations_dir)

if __name__ == "__main__":
    main()
