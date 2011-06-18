field "0101", "KBV-Prüfnummer", 16, :a

section "0020" do
  s.field "8000", 1, 1, :required, "Satzart"
  s.field "8100", 1, 1, :required, "Satzlänge"
  s.field "9105", 1, 1, :required, "Ordnungsnummer des Datenträgers dieses Datenpakets"
end

section "0021" do
  has_field "8000", 1, 1, :required, "Satzart"
  has_field "8100", 1, 1, :required, "Satzlänge"
end

section "8220" do
  has_field "8000", 1, 1, :required, "Satzart"
  has_field "8100", 1, 1, :required, "Satzlänge"
  has_field "9212", 1, 1, :required, "Version der Datensatzbeschreibung"
  has_field "0201", 1, 1, :required, "Betriebs- (BSNR) oder Nebenstellenbetriebsstättennummer (NBSNR)",
    :comment => "Gemeint ist hier der Einweiser; kann als Arztnummer/Arztident bei Nicht-Kassenärzten verwendet werden"
  has_field "0203", 1, 1, :required, "(N)BSNR-Bezeichnung"
  # has_field "0212", 1, 1,
end

