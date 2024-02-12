#!/usr/bin/env python3

import sys,re
from os.path import basename
# from functools import cache


BENCHMARK_DIR = "<your folder>/rv32-benchmarks/individual-instructions"

meta_keys = {
    "[F]":["pc","inst"],
    "[D]":["pc","opc","rd","rs1","rs2","funct3","funct7","imm","shamt"],
    "[R]":["addr_rs1","addr_rs2","data_rs1","data_rs2"],
    "[E]":["pc_address","alu_result","branch_taken"]
}

cache = {}

def check(hypo, gold):
    skipped_insn = [
        '0ff0000f',# skip fence
        'c0001073',# skip unimp
        '00ff00ff',# skip invalid, appears in lw.trace 709
        'ff00ff00',# skip c.fsw, appears in lw.trace 713
        'f00ff00f' # skip invalid, appears in lw.trace 721.
    ]
    if hypo[0].strip().split()[-1] == gold[0].strip().split()[-1] in skipped_insn:
        return False
    return any(h.strip() != g.strip() for h,g in zip(hypo, gold))

def linter(line_our, line_ref, buf):
    global meta_keys
    def push(line):
        buf.append(line)
    # skip identical line
    if line_our.strip() == line_ref.strip():
        return
    # must aligned for the tag
    assert line_our[:3] == line_ref[:3]

    line_indicator = line_ref[:3]
    our_values = line_our[3:].split()
    ref_values = line_ref[3:].split()
    prefix = '\t\t'
    def diff_core(line_indicator, our_values, ref_values):
        keys = meta_keys[line_indicator]
        push(f"\t{line_indicator}")
        for i in range(len(keys)):
            if our_values[i] != ref_values[i]:
                push(f"{prefix}{keys[i]} differs: ours:{our_values[i]}\tgold:{ref_values[i]}")
    diff_core(line_indicator, our_values, ref_values)



def get_asm(path, pc_val, insn):
    # @cache
    def get_asm_content(path):
        global cache
        if cache: return cache
        benchmark_dir = BENCHMARK_DIR
        filename = basename(path.strip())[:-6]
        with open(f'{benchmark_dir}/{filename}.d', 'r') as f:
            data = f.readlines()
        def parse(line):
            pattern = r'([0-9a-fA-F]{7}):(\\t|\s)*([0-9a-fA-F]{8})\s+(.*)'
            search_res = re.search(pattern, line)
            return search_res.groups() if search_res else None
        parsed = list(parse(line) for line in data)
        cache = {addr: (inst, asmb) for addr, _, inst, asmb in filter(lambda x: x is not None, parsed)}
        return cache
    pc_addr = pc_val.strip()[1:] # eliminate the leading 0, as missing in *.d file
    asm = get_asm_content(path)
    return asm[pc_addr] if pc_addr in asm else (insn, f"addr:{pc_addr} Not found for file {path}")

if __name__ == "__main__":
    diff_found = False
    (ours, reference) = sys.argv[1:3]
    assert ours.strip()[-6:] == reference.strip()[-6:] == ".trace" # compared file should ends with '.trace'
    with open(ours, 'r') as f1:
        d_our = f1.readlines()
    with open(reference, 'r') as f2:
        d_ref = f2.readlines()
    file_to_write = reference + '.diff'
    succinct_file_to_write = reference + '.dif'
    d_our = d_our[:len(d_ref)]
    buf = []
    succinct = []
    line_count_of_single_inst = len(meta_keys)
    for i in range(0, len(d_ref), line_count_of_single_inst):
        if check(d_our[i:i+line_count_of_single_inst], d_ref[i:i+line_count_of_single_inst]):
            diff_found = True
            addr, insn = d_ref[i][3:].split()
            inst, assembly = get_asm(reference, addr, insn)
            inst_line = f"line-{i+1}\t diff @ addr:{addr}, inst:{inst} assembly:{assembly}"
            buf.append(inst_line)
            succinct.append(inst_line)
            for l1, l2 in zip(d_our[i:i+line_count_of_single_inst], d_ref[i:i+line_count_of_single_inst]):
                linter(l1, l2, buf)
    with open(file_to_write, 'w') as out:
        out.write('\n'.join(buf))
    with open(succinct_file_to_write, 'w') as ou:
        ou.write('\n'.join(succinct))
    exit(diff_found)
