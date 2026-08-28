#!/usr/bin/env python3
"""
AES-128 Reference Model — Independent verification reference.

This Python implementation of AES-128 encryption is used to:
  1. Generate expected ciphertext for RTL verification
  2. Generate round-by-round intermediate values for debugging
  3. Cross-check test vectors against the FIPS-197 specification

WARNING: This is NOT a proof that the RTL is correct.
         It is an independent reference for comparison.

Usage:
    python aes128_ref.py
"""

# AES S-box (FIPS-197 Figure 7)
SBOX = [
    0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76,
    0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0,
    0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15,
    0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75,
    0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84,
    0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf,
    0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8,
    0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2,
    0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73,
    0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb,
    0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79,
    0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08,
    0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a,
    0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e,
    0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf,
    0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16,
]

# Round constants
RCON = [0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36]


def bytes_to_state(b):
    """Convert 16 bytes to 4x4 state matrix (column-major, FIPS-197)."""
    state = [[0]*4 for _ in range(4)]
    for i in range(16):
        state[i % 4][i // 4] = b[i]
    return state


def state_to_bytes(state):
    """Convert 4x4 state matrix back to 16 bytes."""
    b = []
    for col in range(4):
        for row in range(4):
            b.append(state[row][col])
    return b


def sub_bytes(state):
    for r in range(4):
        for c in range(4):
            state[r][c] = SBOX[state[r][c]]
    return state


def shift_rows(state):
    state[1] = state[1][1:] + state[1][:1]
    state[2] = state[2][2:] + state[2][:2]
    state[3] = state[3][3:] + state[3][:3]
    return state


def xtime(b):
    return ((b << 1) ^ (0x1b if b & 0x80 else 0)) & 0xff


def mix_single_column(col):
    t = col[0] ^ col[1] ^ col[2] ^ col[3]
    u = col[0]
    col[0] ^= xtime(col[0] ^ col[1]) ^ t
    col[1] ^= xtime(col[1] ^ col[2]) ^ t
    col[2] ^= xtime(col[2] ^ col[3]) ^ t
    col[3] ^= xtime(col[3] ^ u) ^ t
    return col


def mix_columns(state):
    for c in range(4):
        col = [state[r][c] for r in range(4)]
        col = mix_single_column(col)
        for r in range(4):
            state[r][c] = col[r]
    return state


def add_round_key(state, round_key):
    for r in range(4):
        for c in range(4):
            state[r][c] ^= round_key[r][c]
    return state


def key_expansion(key_bytes):
    """Expand 16-byte key into 11 round keys (each 4x4 matrix)."""
    # Convert to words (4 bytes each)
    words = []
    for i in range(4):
        words.append(key_bytes[4*i:4*i+4])

    for i in range(4, 44):
        temp = list(words[i-1])
        if i % 4 == 0:
            # RotWord
            temp = temp[1:] + temp[:1]
            # SubWord
            temp = [SBOX[b] for b in temp]
            # XOR Rcon
            temp[0] ^= RCON[i // 4]
        words.append([a ^ b for a, b in zip(words[i-4], temp)])

    # Convert words to round keys (4x4 state matrices)
    round_keys = []
    for rk in range(11):
        key_bytes_rk = []
        for w in range(4):
            key_bytes_rk.extend(words[rk * 4 + w])
        round_keys.append(bytes_to_state(key_bytes_rk))

    return round_keys


def aes128_encrypt(plaintext_bytes, key_bytes, verbose=False):
    """Encrypt a 16-byte plaintext with a 16-byte key. Returns 16 ciphertext bytes."""
    state = bytes_to_state(plaintext_bytes)
    round_keys = key_expansion(key_bytes)

    if verbose:
        print(f"Round  0 input:    {bytes_to_hex(state_to_bytes(state))}")
        print(f"Round  0 key:      {bytes_to_hex(state_to_bytes(round_keys[0]))}")

    # Initial AddRoundKey
    state = add_round_key(state, round_keys[0])
    if verbose:
        print(f"Round  0 output:   {bytes_to_hex(state_to_bytes(state))}")

    # Rounds 1-9
    for rnd in range(1, 10):
        state = sub_bytes(state)
        if verbose:
            print(f"Round {rnd:2d} SubBytes:  {bytes_to_hex(state_to_bytes(state))}")
        state = shift_rows(state)
        if verbose:
            print(f"Round {rnd:2d} ShiftRows: {bytes_to_hex(state_to_bytes(state))}")
        state = mix_columns(state)
        if verbose:
            print(f"Round {rnd:2d} MixCols:   {bytes_to_hex(state_to_bytes(state))}")
        state = add_round_key(state, round_keys[rnd])
        if verbose:
            print(f"Round {rnd:2d} AddRK:     {bytes_to_hex(state_to_bytes(state))}")
            print(f"Round {rnd:2d} key:       {bytes_to_hex(state_to_bytes(round_keys[rnd]))}")

    # Round 10 (final — no MixColumns)
    state = sub_bytes(state)
    if verbose:
        print(f"Round 10 SubBytes:  {bytes_to_hex(state_to_bytes(state))}")
    state = shift_rows(state)
    if verbose:
        print(f"Round 10 ShiftRows: {bytes_to_hex(state_to_bytes(state))}")
    state = add_round_key(state, round_keys[10])
    if verbose:
        print(f"Round 10 AddRK:     {bytes_to_hex(state_to_bytes(state))}")
        print(f"Round 10 key:       {bytes_to_hex(state_to_bytes(round_keys[10]))}")

    return state_to_bytes(state)


def bytes_to_hex(b):
    return ''.join(f'{x:02x}' for x in b)


def hex_to_bytes(h):
    return [int(h[i:i+2], 16) for i in range(0, len(h), 2)]


def run_test(key_hex, pt_hex, expected_ct_hex, name, verbose=False):
    key = hex_to_bytes(key_hex)
    pt = hex_to_bytes(pt_hex)
    expected = hex_to_bytes(expected_ct_hex)

    if verbose:
        print(f"\n{'='*60}")
        print(f"Test: {name}")
        print(f"Key:  {key_hex}")
        print(f"PT:   {pt_hex}")
        print(f"{'='*60}")

    ct = aes128_encrypt(pt, key, verbose=verbose)
    ct_hex = bytes_to_hex(ct)

    if ct == expected:
        print(f"PASS: {name}")
        print(f"  CT: {ct_hex}")
        return True
    else:
        print(f"FAIL: {name}")
        print(f"  Expected: {expected_ct_hex}")
        print(f"  Actual:   {ct_hex}")
        return False


if __name__ == '__main__':
    print("=" * 60)
    print("AES-128 Python Reference Model")
    print("=" * 60)
    print()

    results = []

    # Test 1: FIPS-197 Appendix B
    results.append(run_test(
        "000102030405060708090a0b0c0d0e0f",
        "00112233445566778899aabbccddeeff",
        "69c4e0d86a7b0430d8cdb78070b4c55a",
        "FIPS-197 Appendix B",
        verbose=True
    ))

    # Test 2-5: NIST SP 800-38A F.1.1
    results.append(run_test(
        "2b7e151628aed2a6abf7158809cf4f3c",
        "6bc1bee22e409f96e93d7e117393172a",
        "3ad77bb40d7a3660a89ecaf32466ef97",
        "NIST SP800-38A Block 1"
    ))

    results.append(run_test(
        "2b7e151628aed2a6abf7158809cf4f3c",
        "ae2d8a571e03ac9c9eb76fac45af8e51",
        "f5d3d58503b9699de785895a96fdbaaf",
        "NIST SP800-38A Block 2"
    ))

    results.append(run_test(
        "2b7e151628aed2a6abf7158809cf4f3c",
        "30c81c46a35ce411e5fbc1191a0a52ef",
        "43b1cd7f598ece23881b00e3ed030688",
        "NIST SP800-38A Block 3"
    ))

    results.append(run_test(
        "2b7e151628aed2a6abf7158809cf4f3c",
        "f69f2445df4f9b17ad2b417be66c3710",
        "7b0c785e27e8ad3f8223207104725dd4",
        "NIST SP800-38A Block 4"
    ))

    # Test 6: All zeros
    results.append(run_test(
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "66e94bd4ef8a2c3b884cfa59ca342b2e",
        "All-zero key/plaintext"
    ))

    # Summary
    passed = sum(results)
    total = len(results)
    print()
    print("=" * 60)
    print(f"Python Reference Model: {passed}/{total} tests passed")
    if passed == total:
        print("STATUS: PASS")
    else:
        print("STATUS: FAIL")
    print("=" * 60)
