#basin_feats[, circ_area := perimeter ^ 2 / (4 * pi)]
#basin_feats[, sqr_area := perimeter ^ 2 / 4]

ggplot(basin_feats, aes(fractal)) +
  geom_density()+
  theme_light()

ggplot(basin_feats[gc < 3], aes(log(area), log(perimeter), col = log(gc))) +
  geom_point() +
  theme_light()

ggplot(basin_feats) +
  geom_smooth(aes(log(perimeter), log(area), col = region), method = 'lm', se = F) +
  geom_smooth(aes(log(perimeter), log(circ_area),  col = 'circle'), method = 'lm', se = F) +
  theme_light()

ggplot(basin_feats, aes(log(area), log(gc), group = pfaf_id, col = region)) +
  geom_line() +
  #geom_smooth(method = 'lm', se = F) +
  theme_light()
