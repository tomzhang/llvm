; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+ssse3           | FileCheck %s --check-prefixes=SSSE3,SSSE3_SLOW
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+ssse3,fast-hops | FileCheck %s --check-prefixes=SSSE3,SSSE3_FAST
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx             | FileCheck %s --check-prefixes=AVX,AVX1,AVX1_SLOW
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx,fast-hops   | FileCheck %s --check-prefixes=AVX,AVX1,AVX1_FAST
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx2            | FileCheck %s --check-prefixes=AVX,AVX2,AVX2_SLOW
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx2,fast-hops  | FileCheck %s --check-prefixes=AVX,AVX2,AVX2_FAST

; The next 8 tests check for matching the horizontal op and eliminating the shuffle.
; PR34111 - https://bugs.llvm.org/show_bug.cgi?id=34111

define <4 x float> @hadd_v4f32(<4 x float> %a) {
; SSSE3-LABEL: hadd_v4f32:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    haddps %xmm0, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hadd_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vhaddps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a02 = shufflevector <4 x float> %a, <4 x float> undef, <2 x i32> <i32 0, i32 2>
  %a13 = shufflevector <4 x float> %a, <4 x float> undef, <2 x i32> <i32 1, i32 3>
  %hop = fadd <2 x float> %a02, %a13
  %shuf = shufflevector <2 x float> %hop, <2 x float> undef, <4 x i32> <i32 undef, i32 undef, i32 0, i32 1>
  ret <4 x float> %shuf
}

define <8 x float> @hadd_v8f32a(<8 x float> %a) {
; SSSE3-LABEL: hadd_v8f32a:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movaps %xmm0, %xmm2
; SSSE3-NEXT:    haddps %xmm1, %xmm2
; SSSE3-NEXT:    movddup {{.*#+}} xmm0 = xmm2[0,0]
; SSSE3-NEXT:    movaps %xmm2, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hadd_v8f32a:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vhaddps %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovddup {{.*#+}} xmm1 = xmm0[0,0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hadd_v8f32a:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vhaddps %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[0,0,2,1]
; AVX2-NEXT:    retq
  %a0 = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %a1 = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %hop = fadd <4 x float> %a0, %a1
  %shuf = shufflevector <4 x float> %hop, <4 x float> undef, <8 x i32> <i32 undef, i32 undef, i32 0, i32 1, i32 undef, i32 undef, i32 2, i32 3>
  ret <8 x float> %shuf
}

define <8 x float> @hadd_v8f32b(<8 x float> %a) {
; SSSE3-LABEL: hadd_v8f32b:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    haddps %xmm0, %xmm0
; SSSE3-NEXT:    haddps %xmm1, %xmm1
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hadd_v8f32b:
; AVX:       # %bb.0:
; AVX-NEXT:    vhaddps %ymm0, %ymm0, %ymm0
; AVX-NEXT:    retq
  %a0 = shufflevector <8 x float> %a, <8 x float> undef, <8 x i32> <i32 0, i32 2, i32 undef, i32 undef, i32 4, i32 6, i32 undef, i32 undef>
  %a1 = shufflevector <8 x float> %a, <8 x float> undef, <8 x i32> <i32 1, i32 3, i32 undef, i32 undef, i32 5, i32 7, i32 undef, i32 undef>
  %hop = fadd <8 x float> %a0, %a1
  %shuf = shufflevector <8 x float> %hop, <8 x float> undef, <8 x i32> <i32 0, i32 1, i32 0, i32 1, i32 4, i32 5, i32 4, i32 5>
  ret <8 x float> %shuf
}

define <4 x float> @hsub_v4f32(<4 x float> %a) {
; SSSE3-LABEL: hsub_v4f32:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    hsubps %xmm0, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hsub_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vhsubps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a02 = shufflevector <4 x float> %a, <4 x float> undef, <2 x i32> <i32 0, i32 2>
  %a13 = shufflevector <4 x float> %a, <4 x float> undef, <2 x i32> <i32 1, i32 3>
  %hop = fsub <2 x float> %a02, %a13
  %shuf = shufflevector <2 x float> %hop, <2 x float> undef, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  ret <4 x float> %shuf
}

define <8 x float> @hsub_v8f32a(<8 x float> %a) {
; SSSE3-LABEL: hsub_v8f32a:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movaps %xmm0, %xmm2
; SSSE3-NEXT:    hsubps %xmm1, %xmm2
; SSSE3-NEXT:    movddup {{.*#+}} xmm0 = xmm2[0,0]
; SSSE3-NEXT:    movaps %xmm2, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hsub_v8f32a:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vhsubps %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovddup {{.*#+}} xmm1 = xmm0[0,0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hsub_v8f32a:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vhsubps %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[0,0,2,1]
; AVX2-NEXT:    retq
  %a0 = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %a1 = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %hop = fsub <4 x float> %a0, %a1
  %shuf = shufflevector <4 x float> %hop, <4 x float> undef, <8 x i32> <i32 undef, i32 undef, i32 0, i32 1, i32 undef, i32 undef, i32 2, i32 3>
  ret <8 x float> %shuf
}

define <8 x float> @hsub_v8f32b(<8 x float> %a) {
; SSSE3-LABEL: hsub_v8f32b:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    hsubps %xmm0, %xmm0
; SSSE3-NEXT:    hsubps %xmm1, %xmm1
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hsub_v8f32b:
; AVX:       # %bb.0:
; AVX-NEXT:    vhsubps %ymm0, %ymm0, %ymm0
; AVX-NEXT:    retq
  %a0 = shufflevector <8 x float> %a, <8 x float> undef, <8 x i32> <i32 0, i32 2, i32 undef, i32 undef, i32 4, i32 6, i32 undef, i32 undef>
  %a1 = shufflevector <8 x float> %a, <8 x float> undef, <8 x i32> <i32 1, i32 3, i32 undef, i32 undef, i32 5, i32 7, i32 undef, i32 undef>
  %hop = fsub <8 x float> %a0, %a1
  %shuf = shufflevector <8 x float> %hop, <8 x float> undef, <8 x i32> <i32 0, i32 1, i32 0, i32 1, i32 4, i32 5, i32 4, i32 5>
  ret <8 x float> %shuf
}

define <2 x double> @hadd_v2f64(<2 x double> %a) {
; SSSE3_SLOW-LABEL: hadd_v2f64:
; SSSE3_SLOW:       # %bb.0:
; SSSE3_SLOW-NEXT:    movapd %xmm0, %xmm1
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSSE3_SLOW-NEXT:    addsd %xmm0, %xmm1
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm0 = xmm1[0,0]
; SSSE3_SLOW-NEXT:    retq
;
; SSSE3_FAST-LABEL: hadd_v2f64:
; SSSE3_FAST:       # %bb.0:
; SSSE3_FAST-NEXT:    haddpd %xmm0, %xmm0
; SSSE3_FAST-NEXT:    retq
;
; AVX1_SLOW-LABEL: hadd_v2f64:
; AVX1_SLOW:       # %bb.0:
; AVX1_SLOW-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX1_SLOW-NEXT:    vaddsd %xmm1, %xmm0, %xmm0
; AVX1_SLOW-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; AVX1_SLOW-NEXT:    retq
;
; AVX1_FAST-LABEL: hadd_v2f64:
; AVX1_FAST:       # %bb.0:
; AVX1_FAST-NEXT:    vhaddpd %xmm0, %xmm0, %xmm0
; AVX1_FAST-NEXT:    retq
;
; AVX2_SLOW-LABEL: hadd_v2f64:
; AVX2_SLOW:       # %bb.0:
; AVX2_SLOW-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX2_SLOW-NEXT:    vaddsd %xmm1, %xmm0, %xmm0
; AVX2_SLOW-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; AVX2_SLOW-NEXT:    retq
;
; AVX2_FAST-LABEL: hadd_v2f64:
; AVX2_FAST:       # %bb.0:
; AVX2_FAST-NEXT:    vhaddpd %xmm0, %xmm0, %xmm0
; AVX2_FAST-NEXT:    retq
  %a0 = shufflevector <2 x double> %a, <2 x double> undef, <2 x i32> <i32 0, i32 undef>
  %a1 = shufflevector <2 x double> %a, <2 x double> undef, <2 x i32> <i32 1, i32 undef>
  %hop = fadd <2 x double> %a0, %a1
  %shuf = shufflevector <2 x double> %hop, <2 x double> undef, <2 x i32> <i32 0, i32 0>
  ret <2 x double> %shuf
}

define <2 x double> @hadd_v2f64_scalar_splat(<2 x double> %a) {
; SSSE3_SLOW-LABEL: hadd_v2f64_scalar_splat:
; SSSE3_SLOW:       # %bb.0:
; SSSE3_SLOW-NEXT:    movapd %xmm0, %xmm1
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSSE3_SLOW-NEXT:    addsd %xmm0, %xmm1
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm0 = xmm1[0,0]
; SSSE3_SLOW-NEXT:    retq
;
; SSSE3_FAST-LABEL: hadd_v2f64_scalar_splat:
; SSSE3_FAST:       # %bb.0:
; SSSE3_FAST-NEXT:    haddpd %xmm0, %xmm0
; SSSE3_FAST-NEXT:    retq
;
; AVX1_SLOW-LABEL: hadd_v2f64_scalar_splat:
; AVX1_SLOW:       # %bb.0:
; AVX1_SLOW-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX1_SLOW-NEXT:    vaddsd %xmm1, %xmm0, %xmm0
; AVX1_SLOW-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; AVX1_SLOW-NEXT:    retq
;
; AVX1_FAST-LABEL: hadd_v2f64_scalar_splat:
; AVX1_FAST:       # %bb.0:
; AVX1_FAST-NEXT:    vhaddpd %xmm0, %xmm0, %xmm0
; AVX1_FAST-NEXT:    retq
;
; AVX2_SLOW-LABEL: hadd_v2f64_scalar_splat:
; AVX2_SLOW:       # %bb.0:
; AVX2_SLOW-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX2_SLOW-NEXT:    vaddsd %xmm1, %xmm0, %xmm0
; AVX2_SLOW-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; AVX2_SLOW-NEXT:    retq
;
; AVX2_FAST-LABEL: hadd_v2f64_scalar_splat:
; AVX2_FAST:       # %bb.0:
; AVX2_FAST-NEXT:    vhaddpd %xmm0, %xmm0, %xmm0
; AVX2_FAST-NEXT:    retq
  %a0 = extractelement <2 x double> %a, i32 0
  %a1 = extractelement <2 x double> %a, i32 1
  %hop = fadd double %a0, %a1
  %ins = insertelement <2 x double> undef, double %hop, i32 0
  %shuf = shufflevector <2 x double> %ins, <2 x double> undef, <2 x i32> <i32 0, i32 0>
  ret <2 x double> %shuf
}

define <4 x double> @hadd_v4f64_scalar_splat(<4 x double> %a) {
; SSSE3_SLOW-LABEL: hadd_v4f64_scalar_splat:
; SSSE3_SLOW:       # %bb.0:
; SSSE3_SLOW-NEXT:    movapd %xmm0, %xmm2
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSSE3_SLOW-NEXT:    addsd %xmm0, %xmm2
; SSSE3_SLOW-NEXT:    movapd %xmm1, %xmm3
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm3 = xmm3[1],xmm1[1]
; SSSE3_SLOW-NEXT:    addsd %xmm1, %xmm3
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm0 = xmm2[0,0]
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm1 = xmm3[0,0]
; SSSE3_SLOW-NEXT:    retq
;
; SSSE3_FAST-LABEL: hadd_v4f64_scalar_splat:
; SSSE3_FAST:       # %bb.0:
; SSSE3_FAST-NEXT:    haddpd %xmm0, %xmm0
; SSSE3_FAST-NEXT:    haddpd %xmm1, %xmm1
; SSSE3_FAST-NEXT:    retq
;
; AVX-LABEL: hadd_v4f64_scalar_splat:
; AVX:       # %bb.0:
; AVX-NEXT:    vhaddpd %ymm0, %ymm0, %ymm0
; AVX-NEXT:    retq
  %a0 = extractelement <4 x double> %a, i32 0
  %a1 = extractelement <4 x double> %a, i32 1
  %hop0 = fadd double %a0, %a1
  %a2 = extractelement <4 x double> %a, i32 2
  %a3 = extractelement <4 x double> %a, i32 3
  %hop1 = fadd double %a2, %a3
  %ins = insertelement <4 x double> undef, double %hop0, i32 0
  %ins2 = insertelement <4 x double> %ins,  double %hop1, i32 2
  %shuf = shufflevector <4 x double> %ins2, <4 x double> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  ret <4 x double> %shuf
}

define <4 x double> @hadd_v4f64(<4 x double> %a) {
; SSSE3_SLOW-LABEL: hadd_v4f64:
; SSSE3_SLOW:       # %bb.0:
; SSSE3_SLOW-NEXT:    movapd %xmm0, %xmm2
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSSE3_SLOW-NEXT:    addsd %xmm0, %xmm2
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm0 = xmm2[0,0]
; SSSE3_SLOW-NEXT:    movapd %xmm1, %xmm2
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm1[1]
; SSSE3_SLOW-NEXT:    addsd %xmm1, %xmm2
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm1 = xmm2[0,0]
; SSSE3_SLOW-NEXT:    retq
;
; SSSE3_FAST-LABEL: hadd_v4f64:
; SSSE3_FAST:       # %bb.0:
; SSSE3_FAST-NEXT:    haddpd %xmm0, %xmm0
; SSSE3_FAST-NEXT:    haddpd %xmm1, %xmm1
; SSSE3_FAST-NEXT:    retq
;
; AVX1_SLOW-LABEL: hadd_v4f64:
; AVX1_SLOW:       # %bb.0:
; AVX1_SLOW-NEXT:    vpermilpd {{.*#+}} ymm1 = ymm0[1,0,3,2]
; AVX1_SLOW-NEXT:    vaddpd %ymm1, %ymm0, %ymm0
; AVX1_SLOW-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX1_SLOW-NEXT:    retq
;
; AVX1_FAST-LABEL: hadd_v4f64:
; AVX1_FAST:       # %bb.0:
; AVX1_FAST-NEXT:    vhaddpd %ymm0, %ymm0, %ymm0
; AVX1_FAST-NEXT:    retq
;
; AVX2_SLOW-LABEL: hadd_v4f64:
; AVX2_SLOW:       # %bb.0:
; AVX2_SLOW-NEXT:    vpermilpd {{.*#+}} ymm1 = ymm0[1,0,3,2]
; AVX2_SLOW-NEXT:    vaddpd %ymm1, %ymm0, %ymm0
; AVX2_SLOW-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX2_SLOW-NEXT:    retq
;
; AVX2_FAST-LABEL: hadd_v4f64:
; AVX2_FAST:       # %bb.0:
; AVX2_FAST-NEXT:    vhaddpd %ymm0, %ymm0, %ymm0
; AVX2_FAST-NEXT:    retq
  %a0 = shufflevector <4 x double> %a, <4 x double> undef, <4 x i32> <i32 0, i32 undef, i32 2, i32 undef>
  %a1 = shufflevector <4 x double> %a, <4 x double> undef, <4 x i32> <i32 1, i32 undef, i32 3, i32 undef>
  %hop = fadd <4 x double> %a0, %a1
  %shuf = shufflevector <4 x double> %hop, <4 x double> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  ret <4 x double> %shuf
}

define <2 x double> @hsub_v2f64(<2 x double> %a) {
; SSSE3_SLOW-LABEL: hsub_v2f64:
; SSSE3_SLOW:       # %bb.0:
; SSSE3_SLOW-NEXT:    movapd %xmm0, %xmm1
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSSE3_SLOW-NEXT:    subsd %xmm1, %xmm0
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm0 = xmm0[0,0]
; SSSE3_SLOW-NEXT:    retq
;
; SSSE3_FAST-LABEL: hsub_v2f64:
; SSSE3_FAST:       # %bb.0:
; SSSE3_FAST-NEXT:    hsubpd %xmm0, %xmm0
; SSSE3_FAST-NEXT:    retq
;
; AVX1_SLOW-LABEL: hsub_v2f64:
; AVX1_SLOW:       # %bb.0:
; AVX1_SLOW-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX1_SLOW-NEXT:    vsubsd %xmm1, %xmm0, %xmm0
; AVX1_SLOW-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; AVX1_SLOW-NEXT:    retq
;
; AVX1_FAST-LABEL: hsub_v2f64:
; AVX1_FAST:       # %bb.0:
; AVX1_FAST-NEXT:    vhsubpd %xmm0, %xmm0, %xmm0
; AVX1_FAST-NEXT:    retq
;
; AVX2_SLOW-LABEL: hsub_v2f64:
; AVX2_SLOW:       # %bb.0:
; AVX2_SLOW-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX2_SLOW-NEXT:    vsubsd %xmm1, %xmm0, %xmm0
; AVX2_SLOW-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; AVX2_SLOW-NEXT:    retq
;
; AVX2_FAST-LABEL: hsub_v2f64:
; AVX2_FAST:       # %bb.0:
; AVX2_FAST-NEXT:    vhsubpd %xmm0, %xmm0, %xmm0
; AVX2_FAST-NEXT:    retq
  %a0 = shufflevector <2 x double> %a, <2 x double> undef, <2 x i32> <i32 0, i32 undef>
  %a1 = shufflevector <2 x double> %a, <2 x double> undef, <2 x i32> <i32 1, i32 undef>
  %hop = fsub <2 x double> %a0, %a1
  %shuf = shufflevector <2 x double> %hop, <2 x double> undef, <2 x i32> <i32 undef, i32 0>
  ret <2 x double> %shuf
}

define <4 x double> @hsub_v4f64(<4 x double> %a) {
; SSSE3_SLOW-LABEL: hsub_v4f64:
; SSSE3_SLOW:       # %bb.0:
; SSSE3_SLOW-NEXT:    movapd %xmm0, %xmm2
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSSE3_SLOW-NEXT:    subsd %xmm2, %xmm0
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm0 = xmm0[0,0]
; SSSE3_SLOW-NEXT:    movapd %xmm1, %xmm2
; SSSE3_SLOW-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm1[1]
; SSSE3_SLOW-NEXT:    subsd %xmm2, %xmm1
; SSSE3_SLOW-NEXT:    movddup {{.*#+}} xmm1 = xmm1[0,0]
; SSSE3_SLOW-NEXT:    retq
;
; SSSE3_FAST-LABEL: hsub_v4f64:
; SSSE3_FAST:       # %bb.0:
; SSSE3_FAST-NEXT:    hsubpd %xmm0, %xmm0
; SSSE3_FAST-NEXT:    hsubpd %xmm1, %xmm1
; SSSE3_FAST-NEXT:    retq
;
; AVX1_SLOW-LABEL: hsub_v4f64:
; AVX1_SLOW:       # %bb.0:
; AVX1_SLOW-NEXT:    vpermilpd {{.*#+}} ymm1 = ymm0[1,0,3,2]
; AVX1_SLOW-NEXT:    vsubpd %ymm1, %ymm0, %ymm0
; AVX1_SLOW-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX1_SLOW-NEXT:    retq
;
; AVX1_FAST-LABEL: hsub_v4f64:
; AVX1_FAST:       # %bb.0:
; AVX1_FAST-NEXT:    vhsubpd %ymm0, %ymm0, %ymm0
; AVX1_FAST-NEXT:    retq
;
; AVX2_SLOW-LABEL: hsub_v4f64:
; AVX2_SLOW:       # %bb.0:
; AVX2_SLOW-NEXT:    vpermilpd {{.*#+}} ymm1 = ymm0[1,0,3,2]
; AVX2_SLOW-NEXT:    vsubpd %ymm1, %ymm0, %ymm0
; AVX2_SLOW-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX2_SLOW-NEXT:    retq
;
; AVX2_FAST-LABEL: hsub_v4f64:
; AVX2_FAST:       # %bb.0:
; AVX2_FAST-NEXT:    vhsubpd %ymm0, %ymm0, %ymm0
; AVX2_FAST-NEXT:    retq
  %a0 = shufflevector <4 x double> %a, <4 x double> undef, <4 x i32> <i32 0, i32 undef, i32 2, i32 undef>
  %a1 = shufflevector <4 x double> %a, <4 x double> undef, <4 x i32> <i32 1, i32 undef, i32 3, i32 undef>
  %hop = fsub <4 x double> %a0, %a1
  %shuf = shufflevector <4 x double> %hop, <4 x double> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  ret <4 x double> %shuf
}

define <4 x i32> @hadd_v4i32(<4 x i32> %a) {
; SSSE3-LABEL: hadd_v4i32:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phaddd %xmm0, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hadd_v4i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vphaddd %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a02 = shufflevector <4 x i32> %a, <4 x i32> undef, <4 x i32> <i32 0, i32 2, i32 undef, i32 undef>
  %a13 = shufflevector <4 x i32> %a, <4 x i32> undef, <4 x i32> <i32 1, i32 3, i32 undef, i32 undef>
  %hop = add <4 x i32> %a02, %a13
  %shuf = shufflevector <4 x i32> %hop, <4 x i32> undef, <4 x i32> <i32 0, i32 undef, i32 undef, i32 1>
  ret <4 x i32> %shuf
}

define <8 x i32> @hadd_v8i32a(<8 x i32> %a) {
; SSSE3-LABEL: hadd_v8i32a:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSSE3-NEXT:    phaddd %xmm1, %xmm2
; SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[0,1,0,1]
; SSSE3-NEXT:    movdqa %xmm2, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hadd_v8i32a:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vphaddd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hadd_v8i32a:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vphaddd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,0,2,1]
; AVX2-NEXT:    retq
  %a0 = shufflevector <8 x i32> %a, <8 x i32> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %a1 = shufflevector <8 x i32> %a, <8 x i32> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %hop = add <4 x i32> %a0, %a1
  %shuf = shufflevector <4 x i32> %hop, <4 x i32> undef, <8 x i32> <i32 undef, i32 undef, i32 0, i32 1, i32 undef, i32 undef, i32 2, i32 3>
  ret <8 x i32> %shuf
}

define <8 x i32> @hadd_v8i32b(<8 x i32> %a) {
; SSSE3-LABEL: hadd_v8i32b:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phaddd %xmm0, %xmm0
; SSSE3-NEXT:    phaddd %xmm1, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hadd_v8i32b:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vphaddd %xmm0, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vphaddd %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hadd_v8i32b:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vphaddd %ymm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %a0 = shufflevector <8 x i32> %a, <8 x i32> undef, <8 x i32> <i32 0, i32 2, i32 undef, i32 undef, i32 4, i32 6, i32 undef, i32 undef>
  %a1 = shufflevector <8 x i32> %a, <8 x i32> undef, <8 x i32> <i32 1, i32 3, i32 undef, i32 undef, i32 5, i32 7, i32 undef, i32 undef>
  %hop = add <8 x i32> %a0, %a1
  %shuf = shufflevector <8 x i32> %hop, <8 x i32> undef, <8 x i32> <i32 0, i32 1, i32 0, i32 1, i32 4, i32 5, i32 4, i32 5>
  ret <8 x i32> %shuf
}

define <4 x i32> @hsub_v4i32(<4 x i32> %a) {
; SSSE3-LABEL: hsub_v4i32:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phsubd %xmm0, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hsub_v4i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vphsubd %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a02 = shufflevector <4 x i32> %a, <4 x i32> undef, <4 x i32> <i32 0, i32 2, i32 undef, i32 undef>
  %a13 = shufflevector <4 x i32> %a, <4 x i32> undef, <4 x i32> <i32 1, i32 3, i32 undef, i32 undef>
  %hop = sub <4 x i32> %a02, %a13
  %shuf = shufflevector <4 x i32> %hop, <4 x i32> undef, <4 x i32> <i32 undef, i32 1, i32 0, i32 undef>
  ret <4 x i32> %shuf
}

define <8 x i32> @hsub_v8i32a(<8 x i32> %a) {
; SSSE3-LABEL: hsub_v8i32a:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSSE3-NEXT:    phsubd %xmm1, %xmm2
; SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[0,1,0,1]
; SSSE3-NEXT:    movdqa %xmm2, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hsub_v8i32a:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vphsubd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hsub_v8i32a:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vphsubd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,0,2,1]
; AVX2-NEXT:    retq
  %a0 = shufflevector <8 x i32> %a, <8 x i32> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %a1 = shufflevector <8 x i32> %a, <8 x i32> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %hop = sub <4 x i32> %a0, %a1
  %shuf = shufflevector <4 x i32> %hop, <4 x i32> undef, <8 x i32> <i32 undef, i32 undef, i32 0, i32 1, i32 undef, i32 undef, i32 2, i32 3>
  ret <8 x i32> %shuf
}

define <8 x i32> @hsub_v8i32b(<8 x i32> %a) {
; SSSE3-LABEL: hsub_v8i32b:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phsubd %xmm0, %xmm0
; SSSE3-NEXT:    phsubd %xmm1, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hsub_v8i32b:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vphsubd %xmm0, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vphsubd %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hsub_v8i32b:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vphsubd %ymm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %a0 = shufflevector <8 x i32> %a, <8 x i32> undef, <8 x i32> <i32 0, i32 2, i32 undef, i32 undef, i32 4, i32 6, i32 undef, i32 undef>
  %a1 = shufflevector <8 x i32> %a, <8 x i32> undef, <8 x i32> <i32 1, i32 3, i32 undef, i32 undef, i32 5, i32 7, i32 undef, i32 undef>
  %hop = sub <8 x i32> %a0, %a1
  %shuf = shufflevector <8 x i32> %hop, <8 x i32> undef, <8 x i32> <i32 0, i32 1, i32 0, i32 1, i32 4, i32 5, i32 4, i32 5>
  ret <8 x i32> %shuf
}

define <8 x i16> @hadd_v8i16(<8 x i16> %a) {
; SSSE3-LABEL: hadd_v8i16:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phaddw %xmm0, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hadd_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vphaddw %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a0246 = shufflevector <8 x i16> %a, <8 x i16> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 undef, i32 undef, i32 undef, i32 undef>
  %a1357 = shufflevector <8 x i16> %a, <8 x i16> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
  %hop = add <8 x i16> %a0246, %a1357
  %shuf = shufflevector <8 x i16> %hop, <8 x i16> undef, <8 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 0, i32 1, i32 2, i32 3>
  ret <8 x i16> %shuf
}

define <16 x i16> @hadd_v16i16a(<16 x i16> %a) {
; SSSE3-LABEL: hadd_v16i16a:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSSE3-NEXT:    phaddw %xmm1, %xmm2
; SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[0,1,0,1]
; SSSE3-NEXT:    movdqa %xmm2, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hadd_v16i16a:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vphaddw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hadd_v16i16a:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vphaddw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,0,2,1]
; AVX2-NEXT:    retq
  %a0 = shufflevector <16 x i16> %a, <16 x i16> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %a1 = shufflevector <16 x i16> %a, <16 x i16> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %hop = add <8 x i16> %a0, %a1
  %shuf = shufflevector <8 x i16> %hop, <8 x i16> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 0, i32 1, i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 4, i32 5, i32 6, i32 7>
  ret <16 x i16> %shuf
}

define <16 x i16> @hadd_v16i16b(<16 x i16> %a) {
; SSSE3-LABEL: hadd_v16i16b:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phaddw %xmm0, %xmm0
; SSSE3-NEXT:    phaddw %xmm1, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hadd_v16i16b:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vphaddw %xmm0, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vphaddw %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hadd_v16i16b:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vphaddw %ymm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %a0 = shufflevector <16 x i16> %a, <16 x i16> undef, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 undef, i32 undef, i32 undef, i32 undef, i32 8, i32 10, i32 12, i32 14, i32 undef, i32 undef, i32 undef, i32 undef>
  %a1 = shufflevector <16 x i16> %a, <16 x i16> undef, <16 x i32> <i32 1, i32 3, i32 5, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 9, i32 11, i32 13, i32 15, i32 undef, i32 undef, i32 undef, i32 undef>
  %hop = add <16 x i16> %a0, %a1
  %shuf = shufflevector <16 x i16> %hop, <16 x i16> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 8, i32 9, i32 10, i32 11, i32 8, i32 9, i32 10, i32 11>
  ret <16 x i16> %shuf
}

define <8 x i16> @hsub_v8i16(<8 x i16> %a) {
; SSSE3-LABEL: hsub_v8i16:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phsubw %xmm0, %xmm0
; SSSE3-NEXT:    retq
;
; AVX-LABEL: hsub_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vphsubw %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a0246 = shufflevector <8 x i16> %a, <8 x i16> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 undef, i32 undef, i32 undef, i32 undef>
  %a1357 = shufflevector <8 x i16> %a, <8 x i16> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
  %hop = sub <8 x i16> %a0246, %a1357
  %shuf = shufflevector <8 x i16> %hop, <8 x i16> undef, <8 x i32> <i32 0, i32 undef, i32 2, i32 undef, i32 undef, i32 1, i32 undef, i32 3>
  ret <8 x i16> %shuf
}

define <16 x i16> @hsub_v16i16a(<16 x i16> %a) {
; SSSE3-LABEL: hsub_v16i16a:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSSE3-NEXT:    phsubw %xmm1, %xmm2
; SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[0,1,0,1]
; SSSE3-NEXT:    movdqa %xmm2, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hsub_v16i16a:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vphsubw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hsub_v16i16a:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vphsubw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,0,2,1]
; AVX2-NEXT:    retq
  %a0 = shufflevector <16 x i16> %a, <16 x i16> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %a1 = shufflevector <16 x i16> %a, <16 x i16> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %hop = sub <8 x i16> %a0, %a1
  %shuf = shufflevector <8 x i16> %hop, <8 x i16> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 0, i32 1, i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 4, i32 5, i32 6, i32 7>
  ret <16 x i16> %shuf
}

define <16 x i16> @hsub_v16i16b(<16 x i16> %a) {
; SSSE3-LABEL: hsub_v16i16b:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    phsubw %xmm0, %xmm0
; SSSE3-NEXT:    phsubw %xmm1, %xmm1
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: hsub_v16i16b:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vphsubw %xmm0, %xmm0, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vphsubw %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    vmovddup {{.*#+}} ymm0 = ymm0[0,0,2,2]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: hsub_v16i16b:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vphsubw %ymm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %a0 = shufflevector <16 x i16> %a, <16 x i16> undef, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 undef, i32 undef, i32 undef, i32 undef, i32 8, i32 10, i32 12, i32 14, i32 undef, i32 undef, i32 undef, i32 undef>
  %a1 = shufflevector <16 x i16> %a, <16 x i16> undef, <16 x i32> <i32 1, i32 3, i32 5, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 9, i32 11, i32 13, i32 15, i32 undef, i32 undef, i32 undef, i32 undef>
  %hop = sub <16 x i16> %a0, %a1
  %shuf = shufflevector <16 x i16> %hop, <16 x i16> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 8, i32 9, i32 10, i32 11, i32 8, i32 9, i32 10, i32 11>
  ret <16 x i16> %shuf
}

define <4 x float> @broadcast_haddps_v4f32(<4 x float> %a0) {
; SSSE3-LABEL: broadcast_haddps_v4f32:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    haddps %xmm0, %xmm0
; SSSE3-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0,0,0]
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: broadcast_haddps_v4f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vhaddps %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,0,0,0]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: broadcast_haddps_v4f32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vhaddps %xmm0, %xmm0, %xmm0
; AVX2-NEXT:    vbroadcastss %xmm0, %xmm0
; AVX2-NEXT:    retq
  %1 = tail call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %a0, <4 x float> %a0)
  %2 = shufflevector <4 x float> %1, <4 x float> undef, <4 x i32> zeroinitializer
  ret <4 x float> %2
}

declare <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float>, <4 x float>)
