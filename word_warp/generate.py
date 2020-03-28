import sys, string

MIN_WORD_LEN = 3
MAX_WORD_LEN = 12
allowed = set(string.ascii_lowercase + string.ascii_uppercase)
words = sorted([w for w in list(set([w.strip() for w in sys.stdin])) if set(w) <= allowed and len(w) >= MIN_WORD_LEN and len(w) <= MAX_WORD_LEN], key=len)

print("//")
print("//  Words.h")
print("//  word_warp")
print("//")
print("//  Created by Rory B. Bellows on 25/03/2020.")
print("//  Copyright © 2020 Rory B. Bellows. All rights reserved.")
print("//")
print("")
print("#ifndef Words_h")
print("#define Words_h")
print("")
print("static const size_t words_list_size = %d;" % len(words))
print("static const char* words_list[%d] = {\n\t\"%s\"\n};" % (len(words), '",\n\t"'.join(words)))
print("")
ranges = []
ll = MIN_WORD_LEN
start = 0
end = 0
for i, w in enumerate(words):
	l = len(w)
	if l != ll:
		end = i - 1
		ranges.append((start, end, ll))
		start = i
		ll = l
ranges.append((end + 1, len(words) - 1, MAX_WORD_LEN))
print("static const size_t word_ranges_size = %d;" % len(ranges))
print("static const NSRange word_ranges[%d] = {" % (len(ranges)))
for i, r in enumerate(ranges):
	print("\t(NSRange){ %d, %d }%s // %d" % (r[0], r[1], ',' if i != len(ranges) - 1 else '', r[2]))
print("};")
print("")
print("#endif /* Words_h */")