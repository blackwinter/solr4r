describe Solr4R::Builder do

  before :all do
    @builder = Solr4R::Builder.new
  end

  describe '#add' do

    example do
      @builder.add(employeeId: '05991', office: 'Bridgewater', skills: %w[Perl Java]).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<add>
  <doc>
    <field name="employeeId">05991</field>
    <field name="office">Bridgewater</field>
    <field name="skills">Perl</field>
    <field name="skills">Java</field>
  </doc>
</add>
      EOT
    end

    example do
      @builder.add([{ employeeId: '05992', office: 'Blackwater' }, { employeeId: '05993', skills: 'Ruby' }]).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<add>
  <doc>
    <field name="employeeId">05992</field>
    <field name="office">Blackwater</field>
  </doc>
  <doc>
    <field name="employeeId">05993</field>
    <field name="skills">Ruby</field>
  </doc>
</add>
      EOT
    end

    example do
      @builder.add([id: 42, text: 'blah'], commitWithin: 23).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<add commitWithin="23">
  <doc>
    <field name="id">42</field>
    <field name="text">blah</field>
  </doc>
</add>
      EOT
    end

    example do
      @builder.add([[{ id: 42, text: 'blah' }, { boost: 10.0 }]]).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<add>
  <doc boost="10.0">
    <field name="id">42</field>
    <field name="text">blah</field>
  </doc>
</add>
      EOT
    end

    example do
      @builder.add(id: 42, text: ['blah', boost: 2.0]).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<add>
  <doc>
    <field name="id">42</field>
    <field boost="2.0" name="text">blah</field>
  </doc>
</add>
      EOT
    end

    example do
      @builder.add([[{ id: 42, text: ['blah', boost: 2.0] }, { boost: 10.0 }]], commitWithin: 23).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<add commitWithin="23">
  <doc boost="10.0">
    <field name="id">42</field>
    <field boost="2.0" name="text">blah</field>
  </doc>
</add>
      EOT
    end

    example do
      @builder.add(employeeId: '05991', office: "\fBridgew\ate\r", skills: %w[Perl Java]).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<add>
  <doc>
    <field name="employeeId">05991</field>
    <field name="office">Bridgewte&#13;</field>
    <field name="skills">Perl</field>
    <field name="skills">Java</field>
  </doc>
</add>
      EOT
    end

  end

  describe '#commit' do

    example do
      @builder.commit.should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<commit/>
      EOT
    end

    example do
      @builder.commit(softCommit: true).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<commit softCommit="true"/>
      EOT
    end

  end

  describe '#optimize' do

    example do
      @builder.optimize.should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<optimize/>
      EOT
    end

    example do
      @builder.optimize(maxSegments: 42).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<optimize maxSegments="42"/>
      EOT
    end

  end

  describe '#rollback' do

    example do
      @builder.rollback.should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<rollback/>
      EOT
    end

  end

  describe '#delete' do

    example do
      @builder.delete(id: '05991').should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <id>05991</id>
</delete>
      EOT
    end

    example do
      @builder.delete(id: %w[05991 06000]).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <id>05991</id>
  <id>06000</id>
</delete>
      EOT
    end

    example do
      @builder.delete(query: 'office:Bridgewater').should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater</query>
</delete>
      EOT
    end

    example do
      @builder.delete(query: %w[office:Bridgewater office:Osaka]).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater</query>
  <query>office:Osaka</query>
</delete>
      EOT
    end

    example do
      @builder.delete(query: { office: 'Bridgewater', skills: 'Perl' }).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater</query>
  <query>skills:Perl</query>
</delete>
      EOT
    end

    example do
      @builder.delete(query: { office: %w[Bridgewater Osaka] }).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater</query>
  <query>office:Osaka</query>
</delete>
      EOT
    end

    example do
      @builder.delete(id: %w[05991 06000], query: { office: %w[Bridgewater Osaka] }).should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <id>05991</id>
  <id>06000</id>
  <query>office:Bridgewater</query>
  <query>office:Osaka</query>
</delete>
      EOT
    end

    example do
      @builder.delete(query: "office:\fBridgew\ate\r").should == <<-EOT
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewte&#13;</query>
</delete>
      EOT
    end

  end

end
