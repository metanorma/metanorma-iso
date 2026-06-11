# 008: TableBuilder Creates Complete Tables with Required Properties

## Problem

`TableBuilder` produces tables without required `tblPr` sub-properties:
- `tblW` (table width) — missing or incomplete
- `tblLook` (table look) — missing or has nil attributes
- `tblGrid` (grid columns) — doesn't match row cell count

The reconciler's `reconcile_single_table` in `tables.rb` (line 34-122) must add these. Every table is incomplete until reconciler fixes it.

## Approach

### TableBuilder ensures required properties in `build`

```ruby
class TableBuilder
  def build
    tbl = Wordprocessingml::Table.new

    # Ensure complete tblPr
    tbl.properties ||= Wordprocessingml::TableProperties.new
    tbl.properties.table_width ||= Properties::TableWidth.new(w: 0, type: "auto")
    tbl.properties.table_look ||= DEFAULT_TABLE_LOOK

    # Ensure grid matches column count
    col_count = column_count  # computed from rows
    if tbl.grid.nil? || tbl.grid.columns.size != col_count
      tbl.grid = Wordprocessingml::TableGrid.new(
        columns: Array.new(col_count) { Wordprocessingml::GridCol.new }
      )
    end

    # Ensure cells have tcPr with tcW
    tbl.rows&.each do |row|
      row.cells&.each do |cell|
        cell.properties ||= Wordprocessingml::TableCellProperties.new(
          cell_width: Properties::CellWidth.new(w: 0, type: "auto")
        )
      end
    end

    tbl
  end
end
```

The `DEFAULT_TABLE_LOOK` constant moves from `reconciler/tables.rb` to `TableBuilder` or a shared constants module.

## Files

- **Modify**: `lib/uniword/builder/table_builder.rb`
- **Modify**: `lib/uniword/docx/reconciler/tables.rb` — remove default property creation (keep only gridAfter calculation if needed)

## Acceptance

- Tables have complete tblPr with tblW and tblLook from creation
- Grid columns match row cell counts
- Cells have tcPr with tcW
- No reconciler property creation needed

## Dependencies

- None (TableBuilder is self-contained)
