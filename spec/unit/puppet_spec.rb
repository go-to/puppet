#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet'
require 'puppet_spec/files'

describe Puppet do
  include PuppetSpec::Files

  context "#version" do
    it "should be valid semver" do
      expect(SemanticPuppet::Version).to be_valid Puppet.version
    end
  end

  Puppet::Util::Log.eachlevel do |level|
    it "should have a method for sending '#{level}' logs" do
      expect(Puppet).to respond_to(level)
    end
  end

  it "should be able to change the path" do
    newpath = ENV["PATH"] + File::PATH_SEPARATOR + "/something/else"
    Puppet[:path] = newpath
    expect(ENV["PATH"]).to eq(newpath)
  end

  it 'should propagate --modulepath to base environment' do
    Puppet::Node::Environment.expects(:create).with(
      is_a(Symbol), ['/my/modules'], Puppet::Node::Environment::NO_MANIFEST)

    Puppet.base_context({
      :environmentpath => '/envs',
      :basemodulepath => '/base/modules',
      :modulepath => '/my/modules'
    })
  end

  it 'empty modulepath does not override basemodulepath' do
    Puppet::Node::Environment.expects(:create).with(
      is_a(Symbol), ['/base/modules'], Puppet::Node::Environment::NO_MANIFEST)

    Puppet.base_context({
      :environmentpath => '/envs',
      :basemodulepath => '/base/modules',
      :modulepath => ''
    })
  end

  it 'nil modulepath does not override basemodulepath' do
    Puppet::Node::Environment.expects(:create).with(
      is_a(Symbol), ['/base/modules'], Puppet::Node::Environment::NO_MANIFEST)

    Puppet.base_context({
      :environmentpath => '/envs',
      :basemodulepath => '/base/modules',
      :modulepath => nil
    })
  end

  context "Puppet::OLDEST_RECOMMENDED_RUBY_VERSION" do
    it "should have an oldest recommended ruby version constant" do
      expect(Puppet::OLDEST_RECOMMENDED_RUBY_VERSION).not_to be_nil
    end

    it "should be a string" do
      expect(Puppet::OLDEST_RECOMMENDED_RUBY_VERSION).to be_a_kind_of(String)
    end

    it "should match a semver version" do
      expect(SemanticPuppet::Version).to be_valid(Puppet::OLDEST_RECOMMENDED_RUBY_VERSION)
    end
  end
end
