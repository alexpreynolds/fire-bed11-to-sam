#!/usr/bin/env python

import sys
import json
# import gc
# import ctypes

in_fn = sys.argv[1]
out_fn_prefix = sys.argv[2]

haplotype_not_specified = False

#
# https://stackoverflow.com/a/70154903/19410
#
class RoundingFloat(float):
  __repr__ = staticmethod(lambda x: format(x, '.6f'))
json.encoder.c_make_encoder = None
json.encoder.float = RoundingFloat

ASSEMBLY = 'hg38'

HD = {
  'VN': '0.1',
  'SO': 'coordinate',
  'GO': 'none',
}

SQ = {
  'hg38': [
    {
      'SN': 'chr1',
      'LN': 248956422,
    },
    {
      'SN': 'chr10',
      'LN': 133797422,
    },
    {
      'SN': 'chr11',
      'LN': 135086622,
    },
    {
      'SN': 'chr12',
      'LN': 133275309,
    },
    {
      'SN': 'chr13',
      'LN': 114364328,
    },
    {
      'SN': 'chr14',
      'LN': 107043718,
    },
    {
      'SN': 'chr15',
      'LN': 101991189,
    },
    {
      'SN': 'chr16',
      'LN': 90338345,
    },
    {
      'SN': 'chr17',
      'LN': 83257441,
    },
    {
      'SN': 'chr18',
      'LN': 80373285,
    },
    {
      'SN': 'chr19',
      'LN': 58617616,
    },
    {
      'SN': 'chr2',
      'LN': 242193529,
    },
    {
      'SN': 'chr20',
      'LN': 64444167,
    },
    {
      'SN': 'chr21',
      'LN': 46709983,
    },
    {
      'SN': 'chr22',
      'LN': 50818468,
    },
    {
      'SN': 'chr3',
      'LN': 198295559,
    },
    {
      'SN': 'chr4',
      'LN': 190214555,
    },
    {
      'SN': 'chr5',
      'LN': 181538259,
    },
    {
      'SN': 'chr6',
      'LN': 170805979,
    },
    {
      'SN': 'chr7',
      'LN': 159345973,
    },
    {
      'SN': 'chr8',
      'LN': 145138636,
    },
    {
      'SN': 'chr9',
      'LN': 138394717,
    },
    {
      'SN': 'chrM',
      'LN': 16569,
    },
    {
      'SN': 'chrX',
      'LN': 156040895,
    },
    {
      'SN': 'chrY',
      'LN': 57227415,
    },
  ]
}

def blocks_to_cigar(n_blocks, sizes, offsets):
  res = []
  i = 0
  acc = 0
  for offset, size in zip(offsets, sizes):
    # sys.stderr.write('i {} | offset {} | size {}\n'.format(i, offset, size))
    if i == 0:
      res.append(size)
      res.append('M')
      acc = int(size)
    else:
      N = int(offset) - acc
      if N != 0:
        res.append(str(N))
        res.append('N')
        acc += N
        res.append(str(size))
        res.append('M')
        acc += int(size)
      else:
        acc += int(size)
        res[-2] = str(int(res[-2]) + int(size))
    i += 1
  # sys.stderr.write('res {}\n'.format(res))
  return res

def write_sam_record_for_molecule(identifier, molecule, colors, out_fh):
  QNAME = identifier
  FLAG = str(0) if molecule['strand'] == '+' else str(16)
  RNAME = molecule['chrom']
  POS = str(molecule['start'] + 1)
  MAPQ = str(255)
  CIGAR = ''.join(blocks_to_cigar(molecule['blocks']['count'],
                                  molecule['blocks']['sizes'],
                                  molecule['blocks']['offsets'],))
  RNEXT = '*'
  PNEXT = str(0)
  TLEN = str(molecule['end'] - molecule['start'])
  SEQ = '*'
  QUAL = '*'
  OPT = 'CO:Z:{}'.format(json.dumps(molecule, separators=(',', ':')))
  out_ln_elems = ['\t'.join([
    QNAME,
    FLAG,
    RNAME,
    POS,
    MAPQ,
    CIGAR,
    RNEXT,
    PNEXT,
    TLEN,
    SEQ,
    QUAL,
    OPT,
  ])] + ['']
  out_ln = '\n'.join(out_ln_elems)
  out_fh.write(out_ln)

#
# get bounds of molecule
#
bounds = {}
summary = {}
colors = []
haplotypes = []
with open(in_fn, 'r') as in_fh:
  for line in in_fh:
    elems = line.rstrip().split('\t')
    line = {
      'chrom': elems[0],
      'chromStart': int(elems[1]),
      'chromEnd': int(elems[2]),
      'name': elems[3],
      'haplotype': elems[10],
    }
    haplotype = line['haplotype']
    if haplotype not in bounds:
      haplotypes.append(haplotype)
      bounds[haplotype] = {}
    record = bounds[haplotype]
    identifier = line['name']
    start = line['chromStart']
    end = line['chromEnd']
    if identifier not in record:
      record[identifier] = {
        'start': start,
        'end': end,
      }
    else:
      molecule = record[identifier]
      molecule['start'] = start if start < molecule['start'] else molecule['start']
      molecule['end'] = end

#print(summary)
#print(haplotypes)

for haplotype in haplotypes:
  out_fn = None
  if haplotype_not_specified:
    out_fn = '{}.{}.sam'.format(out_fn_prefix, haplotype)
  else:
    out_fn = '{}.sam'.format(out_fn_prefix)
  summary[haplotype] = {}
  with open(out_fn, 'w') as out_fh:
    #
    # header
    #
    HD_ln_elems = ['\t'.join(['@HD', 'VN:{}'.format(HD['VN']), 'SO:{}'.format(HD['SO']), 'GO:{}'.format(HD['GO'])]), '']
    HD_ln = '\n'.join(HD_ln_elems)
    out_fh.write(HD_ln)
    SQ_ln_elems = ['\t'.join(['@SQ', 'SN:{}'.format(sq['SN']), 'LN:{}'.format(sq['LN'])]) for sq in SQ[ASSEMBLY]] + ['']
    SQ_ln = '\n'.join(SQ_ln_elems)
    out_fh.write(SQ_ln)
    #
    # parse file
    #
    with open(in_fn, 'r') as in_fh:
      for line in in_fh:
        elems = line.rstrip().split('\t')
        line = {
          'chrom': elems[0],
          'chromStart': int(elems[1]),
          'chromEnd': int(elems[2]),
          'name': elems[3],
          'strand': elems[5],
          'color': elems[8],
          'haplotype': elems[10],
        }
        records_by_haplotype = summary[line['haplotype']]
        chrom = line['chrom']
        identifier = line['name']
        strand = line['strand']
        color = line['color']
        start = line['chromStart']
        end = line['chromEnd']
        if identifier not in records_by_haplotype:
          if color not in colors:
            colors.append(color)
          records_by_haplotype[identifier] = {
            'chrom': chrom,
            'start': start,
            'end': end,
            'strand': strand,
            'blocks': {
              'count': 1,
              'sizes': [end - start],
              'offsets': [0],
              'colors': [colors.index(color)],
            },
          }
        else:
          molecule = records_by_haplotype[identifier]
          molecule['start'] = start if start < molecule['start'] else molecule['start']
          molecule['end'] = end
          blocks = molecule['blocks']
          blocks['count'] += 1
          blocks['sizes'].append(end - start)
          blocks['offsets'].append(start - molecule['start'])
          if color not in colors:
            colors.append(color)
          blocks['colors'].append(colors.index(color))
          if molecule['end'] == bounds[haplotype][identifier]['end']:
            # print('---')
            # print(identifier)
            # print(molecule)
            # print(colors)
            molecule['colors'] = colors
            write_sam_record_for_molecule(identifier, molecule, colors, out_fh)
            del molecule
            del bounds[haplotype][identifier]
            # gc.collect()
            # ctypes.CDLL("libc.so.6").malloc_trim(0)
            # sys.exit(0)

# sys.exit(0)
