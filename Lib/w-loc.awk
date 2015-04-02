#!/usr/bin/awk
#purpose: Count TABLEs, VIEWs, FUNCTIONs, etc. [draft]'
$1 == "CREATE" { ++count[$2]; }
$1 == "SELECT" && $2 ~ /^(create|declare)_/ {
		++count[gensub(/\(.*/, "", 1, $2)]
}
END{
		for (entity in count) {
						printf("%s = %d\n", entity, count[entity]);
				}
}
