require("luasnip.session.snippet_collection").clear_snippets("go")

local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("go", {
	s("migrn", {
		t("package migrations\n\n"),
		t("import (\n"),
		t('\t"fmt"\n'),
		t('\t"yaarz/pkg/logger"\n\n'),
		t('\t"github.com/go-pg/migrations/v8"\n'),
		t(")\n\n"),
		t("func init () {\n"),
		fmt('\ttable := "{}"\n', { i(1, "table") }),
		fmt('\tcolumnName := "{}"\n', { i(2, "column") }),
		fmt('\tnewColumnName := "{}"\n', { i(3, "column") }),
		t("\tup := [string]{fmt.Sprintf(`\n"),
		t("\t\tALTER TABLE %s\n"),
		t("\t\tRENAME COLUMN %s TO %s;\n"),
		t("\t`, table, columnName, newColumnName)}\n\n"),
		t("\tdown := [string]{fmt.Sprintf(`\n"),
		t("\t\tALTER TABLE %s\n"),
		t("\t\tRENAME COLUMN %s TO %s;\n"),
		t("\t`, table, newColumnName, columnName)}\n\n"),
		t("\tmigrations.Register(func(db migrations.DB) error {\n"),
		t('\t\tlogger.Infof("rename %s column from %s table to %s, columnName, table, newColumnName)\n'),
		t("\t\tfor _, q := range up {\n"),
		t("\t\t\t_, err := db.Exec(q)\n"),
		t("\t\t\tif err != nil {\n"),
		t("\t\t\t\treturn err\n"),
		t("\t\t\t}\n"),
		t("\t\t}\n"),
		t("\t\treturn nil\n"),
		t("\t}, func(db migrations.DB) error {\n"),
		t('\t\tlogger.Infof("rename %s column from %s table to %s", newColumnName, table, columnName)\n'),
		t("\t\tfor _, q := range down {\n"),
		t("\t\t\t_, err := db.Exec(q)\n"),
		t("\t\t\tif err != nil {\n"),
		t("\t\t\t\treturn err\n"),
		t("\t\t\t}\n"),
		t("\t\t}\n"),
		t("\t\treturn nil\n"),
		t("\t})\n"),
		t("}"),
	}),
})
