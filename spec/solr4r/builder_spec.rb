describe Solr4R::Builder do

  subject { described_class.new(Solr4R::Client.new) }

  describe '#add' do

    example do
      expect(subject.add(employeeId: '05991', office: 'Bridgewater', skills: %w[Perl Java])).to eq(<<-EOT)
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
      expect(subject.add([{ employeeId: '05992', office: 'Blackwater' }, { employeeId: '05993', skills: 'Ruby' }])).to eq(<<-EOT)
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
      expect(subject.add([id: 42, text: 'blah'], commitWithin: 23)).to eq(<<-EOT)
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
      expect(subject.add([[{ id: 42, text: 'blah' }, boost: 10.0]])).to eq(<<-EOT)
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
      expect(subject.add(id: 42, text: ['blah', boost: 2.0])).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<add>
  <doc>
    <field name="id">42</field>
    <field name="text" boost="2.0">blah</field>
  </doc>
</add>
      EOT
    end

    example do
      expect(subject.add([[{ id: 42, text: ['blah', boost: 2.0] }, boost: 10.0]], commitWithin: 23)).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<add commitWithin="23">
  <doc boost="10.0">
    <field name="id">42</field>
    <field name="text" boost="2.0">blah</field>
  </doc>
</add>
      EOT
    end

    example do
      expect(subject.add(employeeId: '05991', office: "\fBridgew\ate\r", skills: %w[Perl Java])).to eq(<<-EOT)
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
      expect(subject.commit).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<commit/>
      EOT
    end

    example do
      expect(subject.commit(softCommit: true)).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<commit softCommit="true"/>
      EOT
    end

  end

  describe '#optimize' do

    example do
      expect(subject.optimize).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<optimize/>
      EOT
    end

    example do
      expect(subject.optimize(maxSegments: 42)).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<optimize maxSegments="42"/>
      EOT
    end

  end

  describe '#rollback' do

    example do
      expect(subject.rollback).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<rollback/>
      EOT
    end

  end

  describe '#delete' do

    example do
      expect(subject.delete(id: '05991')).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <id>05991</id>
</delete>
      EOT
    end

    example do
      expect(subject.delete(id: %w[05991 06000])).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <id>05991</id>
  <id>06000</id>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: 'office:Bridgewater')).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: %w[office:Bridgewater office:Osaka])).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater</query>
  <query>office:Osaka</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: { office: 'Bridgewater', skills: 'Perl' })).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater skills:Perl</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: { office: %w[Bridgewater Osaka] })).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewater office:Osaka</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: { office: 'Bridgewater', _: { type: :edismax } })).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>{!type=edismax}office:Bridgewater</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(id: %w[05991 06000], query: { office: %w[Bridgewater Osaka] })).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <id>05991</id>
  <id>06000</id>
  <query>office:Bridgewater office:Osaka</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: "office:\fBridgew\ate\r")).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridgewte&#13;</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: 'office:Bridge&water')).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridge&amp;water</query>
</delete>
      EOT
    end

    example do
      expect(subject.delete(query: { office: 'Bridge&water' })).to eq(<<-EOT)
<?xml version="1.0" encoding="UTF-8"?>
<delete>
  <query>office:Bridge&amp;water</query>
</delete>
      EOT
    end

  end

  example do
    expect{described_class.new(Solr4R::Client.new(core: 'foo'))}.not_to raise_error(NoMethodError, /core=/)
  end

end
