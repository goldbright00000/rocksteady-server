/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- DROP DATABASE IF EXISTS rocksteady;
-- CREATE DATABASE rocksteady;
-- use rocksteady;


DROP TABLE IF EXISTS characteristics;


CREATE TABLE characteristics (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY characteristics_unique_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;




DROP TABLE IF EXISTS colour_palette_colours;


CREATE TABLE colour_palette_colours (
  id int(11) NOT NULL AUTO_INCREMENT,
  colour_palette_id int(11) NOT NULL,
  colour_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  priority int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE KEY colour_palette_colours_unique_idx (colour_palette_id, colour_id),
  CONSTRAINT colour_palette_colours_colour_palette_id_fk FOREIGN KEY (colour_palette_id) REFERENCES colour_palettes (id) ON DELETE CASCADE,
  CONSTRAINT colour_palette_colours_colour_id_fk FOREIGN KEY (colour_id) REFERENCES colours (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS colour_palettes;


CREATE TABLE colour_palettes (
  id int(11) NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS colours;


CREATE TABLE colours (
  id int(11) NOT NULL,
  display_name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  display_rgb varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  print_cmyk varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  display_colour tinyint(1) DEFAULT 0,
  colour_group_id int(11),
  PRIMARY KEY (id),
  UNIQUE KEY colours_unique_idx (display_name),
  KEY `display_rgb` (`display_rgb`),
  CONSTRAINT colours_colour_group_id_fk FOREIGN KEY (colour_group_id) REFERENCES colour_groups(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS colour_groups;

CREATE TABLE colour_groups (
  id int(11) NOT NULL AUTO_INCREMENT,
  display_name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  default_colour_id INT(11),
  PRIMARY KEY(id),
  UNIQUE KEY colour_groups_unique_idx(display_name),
  CONSTRAINT colour_group_default_colour_id_fk FOREIGN KEY (default_colour_id) REFERENCES colours (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS complementary_colours;

CREATE TABLE complementary_colours (
  id int(11) NOT NULL AUTO_INCREMENT,
  colour_id int(11) DEFAULT NULL,
  complementary_colour_id int(11) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY complementary_colours_unique_idx (colour_id,complementary_colour_id),
  CONSTRAINT complementary_colours_colour_id_fk FOREIGN KEY (colour_id) REFERENCES colours (id) ON DELETE CASCADE,
  CONSTRAINT complementary_colours_complementary_colour_id_fk FOREIGN KEY (complementary_colour_id) REFERENCES colours (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS component_decals;


CREATE TABLE component_decals (
  id int(11) NOT NULL AUTO_INCREMENT,
  component_id int(11) NOT NULL,
  decal_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY component_decals_unique_idx (component_id, decal_id),
  KEY component_decals_decal_id_idx (decal_id),
  CONSTRAINT component_decals_component_id_fk FOREIGN KEY (component_id) REFERENCES components (id) ON DELETE CASCADE,
  CONSTRAINT component_decals_decal_id_fk FOREIGN KEY (decal_id) REFERENCES decals (id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS components;


CREATE TABLE components (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  default_shape_id char(64) NOT NULL,
  manufacturer_id int(11) NOT NULL,
  position_id int(11) NOT NULL,
  colour_palette_id int(11) NOT NULL,
  surface_material_id int(11) NOT NULL,
  curvature_id int(11) NOT NULL,
  texture_id int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY components_unique_idx (position_id, manufacturer_id, default_shape_id, colour_palette_id, surface_material_id, curvature_id, texture_id),
  KEY components_texture_id_idx (texture_id),
  CONSTRAINT components_manufacturer_id_fk FOREIGN KEY (manufacturer_id) REFERENCES manufacturers (id) ON DELETE CASCADE,
  CONSTRAINT components_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE,
  CONSTRAINT components_surface_material_id_fk FOREIGN KEY (surface_material_id) REFERENCES surface_materials (id) ON DELETE CASCADE,
  CONSTRAINT components_texture_id_fk FOREIGN KEY (texture_id) REFERENCES textures (id) ON DELETE CASCADE,
  CONSTRAINT components_curvature_id_fk FOREIGN KEY (curvature_id) REFERENCES curvatures (id) ON DELETE CASCADE,
  CONSTRAINT components_default_shape_id_fk FOREIGN KEY (default_shape_id) REFERENCES shapes (id) ON DELETE CASCADE,
  CONSTRAINT components_colour_palette_id_fk FOREIGN KEY (colour_palette_id) REFERENCES colour_palettes (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS constraints;


CREATE TABLE constraints (
  id int(11) NOT NULL AUTO_INCREMENT,
  lower_limit decimal(10,3) DEFAULT NULL,
  upper_limit decimal(10,3) DEFAULT NULL,
  exact_value decimal(10,3) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  characteristic_id int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY constraints_unique_idx (characteristic_id,lower_limit,upper_limit,exact_value),
  KEY constraints_characteristic_id_exact_value_idx (characteristic_id, exact_value),
  CONSTRAINT constraints_characteristic_id_fk FOREIGN KEY (characteristic_id) REFERENCES characteristics (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS container_characteristics;


CREATE TABLE container_characteristics (
  id int(11) NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  description varchar(1025) COLLATE utf8_unicode_ci NOT NULL,
  container_type varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  internal_length int(11) DEFAULT NULL,
  internal_width int(11) DEFAULT NULL,
  internal_height int(11) DEFAULT NULL,
  internal_diameter int(11) DEFAULT NULL,
  external_length int(11) DEFAULT NULL,
  external_width int(11) DEFAULT NULL,
  external_height int(11) DEFAULT NULL,
  external_diameter int(11) DEFAULT NULL,
  weight int(11) DEFAULT NULL,
  cost_of_container decimal(10,3) DEFAULT NULL,
  shipping_cost decimal(10,3) DEFAULT NULL,
  total_cost decimal(10,3) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_container_characteristic_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS contrasting_colours;


CREATE TABLE contrasting_colours (
  id int(11) NOT NULL AUTO_INCREMENT,
  colour_id int(11) DEFAULT NULL,
  contrasting_colour_id int(11) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_contrasting_colours_uniquely (colour_id,contrasting_colour_id),
  CONSTRAINT contrasting_colour_id FOREIGN KEY (colour_id) REFERENCES colours (id),
  CONSTRAINT contrasting_colours_colour_id_fk FOREIGN KEY (colour_id) REFERENCES colours (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS currencies;


CREATE TABLE currencies (
  id int(11) NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  iso_code varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  iso_numeric varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  symbol varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  fx_rate decimal(10,6) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY currencies_iso_code (iso_code),
  UNIQUE KEY currencies_iso_numeric (iso_numeric),
  UNIQUE KEY currencies_name (name),
  UNIQUE KEY currencies_symbol (symbol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS curvatures;


CREATE TABLE curvatures (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  ranking tinyint NOT NULL DEFAULT 0,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY curvatures_unique_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS decals;


CREATE TABLE decals (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  thickness decimal(10,3) NOT NULL DEFAULT '0',
  weight_per_m2 decimal(10,3) NOT NULL DEFAULT '0',
  cost_per_m2 decimal(10,3) NOT NULL DEFAULT '0',
  price_per_m2 decimal(10,3) NOT NULL DEFAULT '0',
  description varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  material_folder varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  luminous tinyint(1) DEFAULT '0',
  uv tinyint(1) DEFAULT '0',
  non_slip tinyint(1) DEFAULT '0',
  opacity_id int(11) NOT NULL,
  finish_id int(11) NOT NULL,
  min_ot smallint(3) NOT NULL,
  max_ot smallint(3) NOT NULL,

  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY decals_unique_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS display_map_components;


CREATE TABLE display_map_components (
  id int(11) NOT NULL AUTO_INCREMENT,
  display_map_position_id int(11) NOT NULL,
  x decimal(10,3) NOT NULL DEFAULT '0',
  y decimal(10,3) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  KEY display_map_components_display_map_position_id_fk (display_map_position_id),
  CONSTRAINT display_map_components_display_map_position_id_fk FOREIGN KEY (display_map_position_id) REFERENCES display_map_positions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS display_map_positions;


CREATE TABLE display_map_positions (
  id int(11) NOT NULL AUTO_INCREMENT,
  display_map_id int(11) NOT NULL,
  position_id int(11) NOT NULL,
  x decimal(10,3) NOT NULL DEFAULT '0',
  y decimal(10,3) NOT NULL DEFAULT '0',
  height decimal(10,3) NOT NULL DEFAULT '0',
  width decimal(10,3) NOT NULL DEFAULT '0',
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  rotation int(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  KEY index_display_map_positions_on_display_map_id (display_map_id),
  KEY display_map_positions_position_id_fk (position_id),
  CONSTRAINT display_map_positions_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE,
  CONSTRAINT display_map_positions_display_map_id_fk FOREIGN KEY (display_map_id) REFERENCES display_maps (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS display_map_template_positions;


CREATE TABLE display_map_template_positions (
  id int(11) NOT NULL AUTO_INCREMENT,
  display_map_template_id int(11) NOT NULL,
  position_id int(11) NOT NULL,
  related_position_id INT DEFAULT NULL,
  x int(2) NOT NULL DEFAULT '0',
  y int(2) NOT NULL DEFAULT '0',
  rotation int(3) NOT NULL DEFAULT '0',
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  KEY display_map_template_positions_display_map_template_id_fk (display_map_template_id),
  KEY display_map_template_positions_position_id_fk (position_id),
  CONSTRAINT display_map_template_positions_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE,
  CONSTRAINT display_map_template_positions_display_map_template_id_fk FOREIGN KEY (display_map_template_id) REFERENCES display_map_templates (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS display_map_templates;


CREATE TABLE display_map_templates (
  id int(11) NOT NULL AUTO_INCREMENT,
  kit_type_id int(11) NOT NULL,
  target_category_id int(11) NOT NULL,
  rows int(2) NOT NULL DEFAULT '0',
  columns int(2) NOT NULL DEFAULT '0',
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_display_map_template_on_product_line_and_target_type (kit_type_id,target_category_id),
  KEY display_map_templates_target_category_id_fk (target_category_id),
  CONSTRAINT display_map_templates_kit_type_id_fk FOREIGN KEY (kit_type_id) REFERENCES kit_types (id) ON DELETE CASCADE,
  CONSTRAINT display_map_templates_target_category_id_fk FOREIGN KEY (target_category_id) REFERENCES target_categories (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS display_maps;


CREATE TABLE display_maps (
  id int(11) NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  kit_id int(11) NOT NULL,
  display_map_template_id int(11) NOT NULL,
  height decimal(10,3) NOT NULL DEFAULT '0',
  width decimal(10,3) NOT NULL DEFAULT '0',
  published_at datetime DEFAULT NULL,
  PRIMARY KEY (id),
  KEY display_maps_display_map_template_id_fk (display_map_template_id),
  KEY display_maps_kit_id_fk (kit_id),
  CONSTRAINT display_maps_kit_id_fk FOREIGN KEY (kit_id) REFERENCES kits (id) ON DELETE CASCADE,
  CONSTRAINT display_maps_display_map_template_id_fk FOREIGN KEY (display_map_template_id) REFERENCES display_map_templates (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS feature_placement_removals;

CREATE TABLE `feature_placement_removals` (
  `product_line_id` int(11) NOT NULL,
  `target_category_id` int(11) DEFAULT NULL,
  `target_kit_id` int(11) DEFAULT NULL,
  `position_id` int(11) DEFAULT NULL,
  `feature_id` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `feature_id` (`feature_id`),
  KEY `product_line_id` (`product_line_id`),
  KEY `target_category_id` (`target_category_id`),
  KEY `target_kit_id` (`target_kit_id`),
  KEY `position_id` (`position_id`),
  CONSTRAINT `feature_placement_removals_ibfk_1` FOREIGN KEY (`product_line_id`) REFERENCES `product_lines` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feature_placement_removals_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `features` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feature_placement_removals_ibfk_3` FOREIGN KEY (`target_category_id`) REFERENCES `target_categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feature_placement_removals_ibfk_4` FOREIGN KEY (`target_kit_id`) REFERENCES `target_kits` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feature_placement_removals_ibfk_5` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS feature_placements;


CREATE TABLE feature_placements (
  id int(11) NOT NULL AUTO_INCREMENT,
  product_line_id int(11) NOT NULL,
  target_category_id int(11),
  target_kit_id int(11),
  position_id int(11),
  shape_id char(64),
  feature_id int(11) NOT NULL,
  x decimal(10,6) NOT NULL,
  y decimal(10,6) NOT NULL,
  angle int(11) NOT NULL,
  scale decimal(10,3),
  z_index int(11) NOT NULL,
  icon_id int(11),
  fill_id int(11),
  b1f_id int(11),
  b2f_id int(11),
  b3f_id int(11),
  b4f_id int(11),
  b1w int,
  b2w int,
  b3w int,
  b4w int,
  spacing SMALLINT SIGNED,
  alignment VARCHAR(6),
  font_size SMALLINT(3) UNSIGNED,
  font_family_id int(11),
  height decimal(2,1),
  text VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  flip_x SMALLINT SIGNED,
  flip_y SMALLINT SIGNED,
  stroke_internal_1 tinyint(1),
  stroke_front_1 tinyint(1),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY feature_placements_unique_idx (product_line_id, target_category_id, target_kit_id, position_id, shape_id, feature_id),
  CONSTRAINT feature_placements_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE,
  CONSTRAINT feature_placements_feature_id_fk FOREIGN KEY (feature_id) REFERENCES features (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS feature_properties;


CREATE TABLE feature_properties (
  id int(11) NOT NULL AUTO_INCREMENT,
  feature_id int(11) NOT NULL,
  property_id int(11) NOT NULL,
  editable tinyint(1) NOT NULL DEFAULT '0',
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_feature_properties_uniquely (feature_id,property_id),
  CONSTRAINT feature_properties_property_id_fk FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE,
  CONSTRAINT feature_properties_feature_id_fk FOREIGN KEY (feature_id) REFERENCES features (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS feature_type_properties;


CREATE TABLE feature_type_properties (
  id int(11) NOT NULL AUTO_INCREMENT,
  feature_type_id int(11) NOT NULL,
  property_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_feature_type_properties_uniquely (feature_type_id,property_id),
  KEY feature_type_properties_property_id_fk (property_id),
  CONSTRAINT feature_type_properties_property_id_fk FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE,
  CONSTRAINT feature_type_properties_feature_type_id_fk FOREIGN KEY (feature_type_id) REFERENCES feature_types (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS feature_types;


CREATE TABLE feature_types (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_feature_types_uniquely (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS features;


CREATE TABLE features (
  id int(11) NOT NULL,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  display_name varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  display_order int(11) DEFAULT 100,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  prompt tinyint(1) NOT NULL DEFAULT '0',
  sample_value varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  feature_type_id int(11) NOT NULL,
  visible_to_user tinyint(1) NOT NULL DEFAULT '0',
  presence_regulated tinyint(2) NOT NULL DEFAULT '0',
  value_assigned_by_dct tinyint(1) NOT NULL DEFAULT '0',
  linked tinyint(1) NOT NULL DEFAULT '0',
  contrast_on_build tinyint(1) NOT NULL DEFAULT '0',
  user_specific_information tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE KEY index_features_on_name (name),
  KEY features_feature_type_id_fk (feature_type_id),
  CONSTRAINT features_feature_type_id_fk FOREIGN KEY (feature_type_id) REFERENCES feature_types (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS features_product_lines;


CREATE TABLE features_product_lines (
  feature_id int(11) NOT NULL,
  product_line_id int(11) NOT NULL ,
  PRIMARY KEY (product_line_id, feature_id),
  KEY features_product_lines_product_line_id_fk (product_line_id),
  KEY features_product_lines_feature_id_fk (feature_id),
  CONSTRAINT features_product_lines_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE,
  CONSTRAINT features_product_lines_feature_id_fk FOREIGN KEY (feature_id) REFERENCES features (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS font_palette_fonts;


CREATE TABLE font_palette_fonts (
  id int(11) NOT NULL AUTO_INCREMENT,
  font_palette_id int(11) DEFAULT NULL,
  font_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_font_palette_fonts_on_font_id_and_font_palette_id (font_id,font_palette_id),
  KEY font_palette_fonts_font_palette_id_fk (font_palette_id),
  CONSTRAINT font_palette_fonts_font_id_fk FOREIGN KEY (font_id) REFERENCES fonts (id) ON DELETE CASCADE,
  CONSTRAINT font_palette_fonts_font_palette_id_fk FOREIGN KEY (font_palette_id) REFERENCES font_palettes (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS font_palettes;


CREATE TABLE font_palettes (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_font_palettes_uniquely (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS fonts;


CREATE TABLE fonts (
  id int(11) NOT NULL,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  data mediumtext COLLATE utf8_unicode_ci,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_fonts_on_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS icons;


CREATE TABLE icons (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  design_category varchar(14) NOT NULL,
  feature_id int(11) DEFAULT NULL,
  extension VARCHAR(4) NOT NULL,
  multicoloured tinyint(1) DEFAULT '0',
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  KEY icons_feature_id_fk (feature_id),
  CONSTRAINT icons_feature_id_fk FOREIGN KEY (feature_id) REFERENCES features (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS icon_tags_icons;


CREATE TABLE icon_tags_icons (
  `icon_id` int(11) NOT NULL,
  `icon_tag_id` int(11) NOT NULL,
  PRIMARY KEY (`icon_id`,`icon_tag_id`),
  KEY `fk_icons_tags_2_idx` (`icon_tag_id`),
  CONSTRAINT `fk_icons_tags_icons` FOREIGN KEY (`icon_id`) REFERENCES `icons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_icons_tags_tags` FOREIGN KEY (`icon_tag_id`) REFERENCES `icon_tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS icon_tags;

CREATE TABLE icon_tags (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS interview_icons;

CREATE TABLE `interview_icons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_line_id` int(11) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `data` mediumtext COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY ii_product_line_id(product_line_id),
  CONSTRAINT ii_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE,
  CONSTRAINT ii_country_id_fk FOREIGN KEY (country_id) REFERENCES countries (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;




DROP TABLE IF EXISTS interview_icon_manufacturers;

CREATE TABLE `interview_icon_manufacturers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `interview_icon_id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `product_line_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT iim_interview_icon_id_fk FOREIGN KEY (interview_icon_id) REFERENCES interview_icons (id) ON DELETE CASCADE,
  CONSTRAINT iim_manufacturers_id_fk FOREIGN KEY (manufacturer_id) REFERENCES manufacturers (id) ON DELETE CASCADE,
  CONSTRAINT iim_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE,
  UNIQUE KEY `interview_icon_id` (`interview_icon_id`,`manufacturer_id`,`product_line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;





DROP TABLE IF EXISTS interview_icon_target_categories;

CREATE TABLE `interview_icon_target_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `interview_icon_id` int(11) NOT NULL,
  `target_category_id` int(11) NOT NULL,
  `product_line_id` int(11) NOT NULL,
  CONSTRAINT iitc_interview_icon_id_fk FOREIGN KEY (interview_icon_id) REFERENCES interview_icons (id) ON DELETE CASCADE,
  CONSTRAINT iitc_target_category_id_fk FOREIGN KEY (target_category_id) REFERENCES target_categories (id) ON DELETE CASCADE,
  CONSTRAINT iitc_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE,
  PRIMARY KEY (`id`),
  UNIQUE KEY `interview_icon_id` (`interview_icon_id`,`target_category_id`,`product_line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




DROP TABLE IF EXISTS interview_icon_rule_sets;

CREATE TABLE `interview_icon_rule_sets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `interview_icon_id` int(11) NOT NULL,
  `rule_set_id` int(11) NOT NULL,
  `product_line_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `interview_icon_id` (`interview_icon_id`,`rule_set_id`,`product_line_id`),
  CONSTRAINT iirs_interview_icon_id_fk FOREIGN KEY (interview_icon_id) REFERENCES interview_icons (id) ON DELETE CASCADE,
  CONSTRAINT iirs_rule_set_id_fk FOREIGN KEY (rule_set_id) REFERENCES rule_sets (id) ON DELETE CASCADE,
  CONSTRAINT iirs_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;






DROP TABLE IF EXISTS kit_components;


CREATE TABLE kit_components (
  id int(11) NOT NULL AUTO_INCREMENT,
  kit_id int(11) NOT NULL,
  component_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  `default` tinyint(1) NOT NULL DEFAULT '0',
  position_id int(11) NOT NULL,
  shape_id char(64) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY kit_components_unique_idx (kit_id, position_id, component_id, shape_id),
  KEY kit_components_component_id_idx (component_id),
  CONSTRAINT kit_components_kit_id_fk FOREIGN KEY (kit_id) REFERENCES kits (id) ON DELETE CASCADE,
  CONSTRAINT kit_components_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id),
  CONSTRAINT kit_components_component_id_fk FOREIGN KEY (component_id) REFERENCES components (id) ON DELETE CASCADE,
  CONSTRAINT kit_components_shape_id_fk FOREIGN KEY (shape_id) REFERENCES shapes (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS kit_types;


CREATE TABLE kit_types (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_kit_types_on_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS kits;


CREATE TABLE kits (
  id int(11) NOT NULL AUTO_INCREMENT,
  parent_id int(11) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  lft int(11) DEFAULT NULL,
  rgt int(11) DEFAULT NULL,
  depth int(11) DEFAULT NULL,
  kit_type_id int(11) NOT NULL,
  subkit_type_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY index_kits_on_parent_id (parent_id),
  KEY kits_kit_type_id_fk (kit_type_id),
  CONSTRAINT kits_kit_type_id_fk FOREIGN KEY (kit_type_id) REFERENCES kit_types (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS manufacturers;


CREATE TABLE manufacturers (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  font_palette_id int(11) DEFAULT NULL,
  colour_palette_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_manufacturers_on_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS merchant_accounts;

CREATE TABLE merchant_accounts (
  iso_currency_code  varchar(3) NOT NULL,
  acc_code           varchar(7) NOT NULL,
  PRIMARY KEY (iso_currency_code),
  CONSTRAINT iso_currency_code_fk FOREIGN KEY (iso_currency_code) REFERENCES currencies (iso_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS positions;


CREATE TABLE positions (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_positions_on_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS `postal_options`;

CREATE TABLE `postal_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(255) NOT NULL,
  `service_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`company_name`,`service_name`) USING BTREE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;




DROP TABLE IF EXISTS product_lines;


CREATE TABLE product_lines (
  id int(11) NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  target_type_id int(11) NOT NULL,
  kit_type_id int(11) NOT NULL,
  regulated int(1) DEFAULT FALSE,
  PRIMARY KEY (id),
  UNIQUE KEY product_lines_unique_idx (target_type_id, kit_type_id),
  CONSTRAINT product_lines_kit_type_id_fk FOREIGN KEY (kit_type_id) REFERENCES kit_types (id) ON DELETE CASCADE,
  CONSTRAINT product_lines_target_type_id_fk FOREIGN KEY (target_type_id) REFERENCES target_types (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS properties;


CREATE TABLE properties (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  source varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Integer',
  `default` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_properties_uniquely (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS country_icons;


CREATE TABLE country_icons (
  id int(11) NOT NULL AUTO_INCREMENT,
  country_id int(11) DEFAULT NULL,
  icon_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY country_icons_country_id_idx (country_id, icon_id),
  CONSTRAINT country_icons_country_id_fk FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE,
  CONSTRAINT country_icons_icon_id_fk FOREIGN KEY (icon_id) REFERENCES icons(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS countries;


CREATE TABLE countries (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  nationality varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  priority int(11) NOT NULL,
  currency_id int(11) NOT NULL,
  address_format varchar(255) NOT NULL,
  iso_numeric varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  iso_code2 varchar(2) COLLATE utf8_unicode_ci NOT NULL,
  discount     DECIMAL(3, 2) NOT NULL DEFAULT 0,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  KEY countries_name_id_idx (name),
  KEY `countries_iso_code2_index` (`iso_code2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS regulation_colour_palette_colours;


CREATE TABLE regulation_colour_palette_colours (
  id int(11) NOT NULL AUTO_INCREMENT,
  regulation_colour_palette_id int(11) NOT NULL,
  colour_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  exclude tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  KEY regulation_col_pal_colours_regulation_col_pal_id_fk (regulation_colour_palette_id),
  KEY regulation_colour_palette_colours_colour_id_fk (colour_id),
  CONSTRAINT regulation_colour_palette_colours_colour_id_fk FOREIGN KEY (colour_id) REFERENCES colours (id) ON DELETE CASCADE,
  CONSTRAINT regulation_col_pal_colours_regulation_col_pal_id_fk FOREIGN KEY (regulation_colour_palette_id) REFERENCES regulation_colour_palettes (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS regulation_colour_palettes;


CREATE TABLE regulation_colour_palettes (
  id int(11) NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  regulation_feature_property_id int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY regulation_colour_palettes_regulation_feature_property_id_idx (regulation_feature_property_id),
  CONSTRAINT regulation_colour_palettes_regulation_feature_property_id_fk FOREIGN KEY (regulation_feature_property_id) REFERENCES regulation_feature_properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS regulation_constraints;


CREATE TABLE regulation_constraints (
  id int(11) NOT NULL AUTO_INCREMENT,
  regulation_id int(11) NOT NULL,
  constraint_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY regulation_constraints_unique_idx (regulation_id, constraint_id),
  CONSTRAINT regulation_constraints_constraint_id_fk FOREIGN KEY (constraint_id) REFERENCES constraints (id) ON DELETE CASCADE,
  CONSTRAINT regulation_constraints_regulation_id_fk FOREIGN KEY (regulation_id) REFERENCES regulations (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS regulation_feature_properties;


CREATE TABLE regulation_feature_properties (
  id int(11) NOT NULL AUTO_INCREMENT,
  regulation_feature_id int(11) NOT NULL,
  property_id int(11) NOT NULL,
  editable tinyint(1) NOT NULL,
  value varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  font_palette_id int(11) DEFAULT NULL,
  regulation_colour_palette_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_regulation_feature_properties_uniquely (regulation_feature_id,property_id),
  KEY regulation_feature_properties_property_id_fk (property_id),
  CONSTRAINT regulation_feature_properties_property_id_fk FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE,
  CONSTRAINT regulation_feature_properties_regulation_feature_id_fk FOREIGN KEY (regulation_feature_id) REFERENCES regulation_features (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS regulation_features;

CREATE TABLE regulation_features (
  id int(11) NOT NULL AUTO_INCREMENT,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  feature_id int(11) NOT NULL,
  position_id int(11) NOT NULL,
  regulation_id int(11) NOT NULL,
  placement_notes varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  requirement tinyint(4) NOT NULL DEFAULT '0',
  placement_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY regulation_features_idx (regulation_id,position_id,feature_id),
  KEY placement_id (placement_id),
  CONSTRAINT regulation_features_feature_id_fk FOREIGN KEY (feature_id) REFERENCES features (id) ON DELETE CASCADE,
  CONSTRAINT regulation_features_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE,
  CONSTRAINT regulation_features_regulation_id_fk FOREIGN KEY (regulation_id) REFERENCES regulations (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS regulation_finishes;

CREATE TABLE regulation_finishes (
  id int(11) NOT NULL AUTO_INCREMENT,
  regulation_id int(11) NOT NULL,
  position_id int(11) NOT NULL,
  finish_id int(11) DEFAULT NULL,
  opacity_id int(11) DEFAULT NULL,
  luminous tinyint(1) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  KEY regulation_finishes_idx (regulation_id, position_id),
  CONSTRAINT regulation_finishes_regulation_id_fk FOREIGN KEY (regulation_id) REFERENCES regulations (id) ON DELETE CASCADE,
  CONSTRAINT regulation_finishes_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;




DROP TABLE IF EXISTS regulation_icons;

CREATE TABLE regulation_icons (
  id int(11) NOT NULL AUTO_INCREMENT,
  regulation_id int(11) NOT NULL,
  icon_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  KEY regulation_icons_unique_idx (regulation_id, icon_id),
  CONSTRAINT regulation_icons_regulation_id_fk FOREIGN KEY (regulation_id) REFERENCES regulations (id) ON DELETE CASCADE,
  CONSTRAINT regulation_icons_icon_id_fk FOREIGN KEY (icon_id) REFERENCES icons (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS regulation_placements;

CREATE TABLE regulation_placements (
  id int(11) NOT NULL AUTO_INCREMENT,
  product_line_id int(11) NOT NULL,
  name varchar(25) COLLATE utf8_unicode_ci NOT NULL,
  target_category_id int(11),
  position_id int(11),
  x decimal(10,6) NOT NULL,
  y decimal(10,6) NOT NULL,
  angle int(11) NOT NULL,
  scale decimal(10,3),
  z_index int(11) NOT NULL,
  icon_id int(11),
  fill_id int(11),
  b1f_id int(11),
  b2f_id int(11),
  b3f_id int(11),
  b4f_id int(11),
  b1w int,
  b2w int,
  b3w int,
  b4w int,
  spacing SMALLINT SIGNED,
  alignment VARCHAR(6),
  font_size SMALLINT(3) UNSIGNED,
  font_family_id int(11),
  height decimal(2,1),
  text VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  flip_x SMALLINT SIGNED,
  flip_y SMALLINT SIGNED,
  stroke_internal_1 tinyint(1),
  stroke_front_1    tinyint(1),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY regulation_placements_unique_idx (product_line_id, target_category_id, position_id, name),
  CONSTRAINT regulation_placements_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE,
  CONSTRAINT regulation_placements_target_category_id_fk FOREIGN KEY (target_category_id) REFERENCES target_categories (id) ON DELETE CASCADE,
  CONSTRAINT regulation_placements_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS regulations;


CREATE TABLE regulations (
  id int(11) NOT NULL AUTO_INCREMENT,
  use_category_id int(11) NOT NULL,
  target_category_id int(11) NOT NULL,
  use_id int(11) NOT NULL,
  rule_set_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  font_palette_id int(11) DEFAULT NULL,
  series_sponsor_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY regulations_use_category_id_fk (use_category_id),
  KEY regulations_target_category_id_fk (target_category_id),
  KEY regulations_use_id_fk (use_id),
  KEY regulations_rule_set_id_fk (rule_set_id),
  CONSTRAINT regulations_rule_set_id_fk FOREIGN KEY (rule_set_id) REFERENCES rule_sets (id) ON DELETE CASCADE,
  CONSTRAINT regulations_use_category_id_fk FOREIGN KEY (use_category_id) REFERENCES use_categories (id) ON DELETE CASCADE,
  CONSTRAINT regulations_target_category_id_fk FOREIGN KEY (target_category_id) REFERENCES target_categories (id) ON DELETE CASCADE,
  CONSTRAINT regulations_use_id_fk FOREIGN KEY (use_id) REFERENCES uses (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS rule_set_icons;


CREATE TABLE rule_set_icons (
  id int(11) NOT NULL AUTO_INCREMENT,
  rule_set_id int(11) NOT NULL,
  icon_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  KEY rule_set_icons_icon_id_fk (icon_id),
  KEY rule_set_icons_rule_set_id_fk (rule_set_id),
  CONSTRAINT rule_set_icons_rule_set_id_fk FOREIGN KEY (rule_set_id) REFERENCES rule_sets (id) ON DELETE CASCADE,
  CONSTRAINT rule_set_icons_icon_id_fk FOREIGN KEY (icon_id) REFERENCES icons (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS rule_sets;


CREATE TABLE rule_sets (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  product_line_id int(11) NOT NULL,
  regulatory_body_id int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY rule_sets_unique_idx (product_line_id, name),
  CONSTRAINT rule_sets_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS seed_load_missing_items;

CREATE TABLE `seed_load_missing_items` (
  `id` int(11) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `type` enum('colour','font','icon') CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`name`,`type`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



DROP TABLE IF EXISTS series_sponsor_icons;


CREATE TABLE series_sponsor_icons (
  id int(11) NOT NULL AUTO_INCREMENT,
  series_sponsor_id int(11) NOT NULL,
  icon_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY series_sponsor_icons_unique_idx (series_sponsor_id,icon_id),
  CONSTRAINT series_sponsor_icons_icon_id_fk FOREIGN KEY (icon_id) REFERENCES icons (id) ON DELETE CASCADE,
  CONSTRAINT series_sponsor_icons_series_sponsor_id_fk FOREIGN KEY (series_sponsor_id) REFERENCES series_sponsors (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS series_sponsors;


CREATE TABLE series_sponsors (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY series_sponsors_unique_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS shape_prices;


CREATE TABLE shape_prices (
  id int(11) NOT NULL AUTO_INCREMENT,
  decal_id int(11) NOT NULL,
  shape_id char(64) NOT NULL,
  price decimal(10,3) NOT NULL DEFAULT '0',
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY shape_prices_unique_idx (decal_id, shape_id),
  CONSTRAINT shape_prices_decal_id_fk FOREIGN KEY (decal_id) REFERENCES decals(id) ON DELETE CASCADE,
  CONSTRAINT shape_prices_shape_id_fk FOREIGN KEY (shape_id) REFERENCES shapes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS shapes;


CREATE TABLE shapes (
  id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,

  component_svg mediumtext COLLATE utf8_unicode_ci,
  bleedcut_svg mediumtext COLLATE utf8_unicode_ci,
  throughcut_svg mediumtext COLLATE utf8_unicode_ci,
  kisscut_svg mediumtext COLLATE utf8_unicode_ci,

  editor_width decimal(10,3) NOT NULL DEFAULT '0',
  editor_height decimal(10,3) NOT NULL DEFAULT '0',
  print_offset_x decimal(10,3) NOT NULL DEFAULT '0',
  print_offset_y decimal(10,3) NOT NULL DEFAULT '0',
  print_area decimal(10,6) NOT NULL DEFAULT '0',
  qron_x decimal(10,3) NOT NULL DEFAULT -1,
  qron_y decimal(10,3) NOT NULL DEFAULT -1,
  qron_rotation decimal(10,1) NOT NULL DEFAULT 360,

  product_line_id int(11) NOT NULL,
  multiple_positions tinyint(1) DEFAULT 0,
  visible_centre_point tinyint(1) DEFAULT 1,
  internal_id int(11) NOT NULL,
  component_curvature_rating SMALLINT(1) DEFAULT NULL,
  perforated_shape_warning tinyint(1) DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY shapes_unique_idx (product_line_id, internal_id),
  CONSTRAINT shapes_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;




DROP TABLE IF EXISTS `shipping_options`;

CREATE TABLE `shipping_options` (
  `id`               INT(11)       NOT NULL AUTO_INCREMENT,
  `iso_code2`        VARCHAR(2)    NOT NULL,
  `postal_option_id` INT(11)       NOT NULL,
  `type_id`          SMALLINT(1)   NOT NULL,
  `price`            DECIMAL(5, 2) NOT NULL,
  `delivery_time`    VARCHAR(6)    NOT NULL,
  `phone_required`   TINYINT(1)    NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `shipping_options_iso_code2_index` (`iso_code2`),
  KEY `shipping_options_type_id_index` (`type_id`),
  KEY `shipping_options_ibfk_2` (`postal_option_id`),
  CONSTRAINT `shipping_options_ibfk_1` FOREIGN KEY (`iso_code2`) REFERENCES `countries` (`iso_code2`),
  CONSTRAINT `shipping_options_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `shipping_option_types` (`id`),
  CONSTRAINT `shipping_options_ibfk_3` FOREIGN KEY (`postal_option_id`) REFERENCES `postal_options` (`id`)
)
  ENGINE = INNODB
  DEFAULT CHARSET = UTF8
  COLLATE = UTF8_UNICODE_CI;






DROP TABLE IF EXISTS `shipping_option_types`;

CREATE TABLE `shipping_option_types` (
    `id` SMALLINT(1) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `name_UNIQUE` (`name` ASC)
)  ENGINE=INNODB DEFAULT CHARACTER SET=UTF8 COLLATE = UTF8_UNICODE_CI;




DROP TABLE IF EXISTS special_classes;


CREATE TABLE special_classes (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY special_classes_unique_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS surface_materials;


CREATE TABLE surface_materials (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY surface_materials_unique_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS surface_profiles;


CREATE TABLE surface_profiles (
  id int(11) NOT NULL AUTO_INCREMENT,
  decal_id int(11) NOT NULL,
  surrounding_environment_id int(11) NOT NULL,
  surface_material_id int(11) NOT NULL,
  texture_id int(11) NOT NULL,
  curvature_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY surface_profiles_unique_idx (decal_id, surrounding_environment_id, surface_material_id, texture_id, curvature_id),
  KEY surface_profiles_decal_id_idx (decal_id),
  KEY surface_profiles_surface_material_id_idx (surface_material_id),
  KEY surface_profiles_texture_id_idx (texture_id),
  KEY surface_profiles_curvature_id_idx (curvature_id),
  CONSTRAINT surface_profiles_decal_id_fk FOREIGN KEY (decal_id) REFERENCES decals (id) ON DELETE CASCADE,
  CONSTRAINT surface_profiles_surface_material_id_fk FOREIGN KEY (surface_material_id) REFERENCES surface_materials (id) ON DELETE CASCADE,
  CONSTRAINT surface_profiles_texture_id_fk FOREIGN KEY (texture_id) REFERENCES textures (id) ON DELETE CASCADE,
  CONSTRAINT surface_profiles_curvature_id_fk FOREIGN KEY (curvature_id) REFERENCES curvatures (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS target_categories;


CREATE TABLE target_categories (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  target_type_id int(11) NOT NULL,
  font_palette_id int(11) DEFAULT NULL,
  colour_palette_id int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY target_categories_unique_idx (target_type_id, name),
  CONSTRAINT target_categories_target_type_id_fk FOREIGN KEY (target_type_id) REFERENCES target_types (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS target_category_positions;


CREATE TABLE target_category_positions (
  id int(11) NOT NULL AUTO_INCREMENT,
  target_category_id int(11) NOT NULL,
  position_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  kit_type_id int(11) NOT NULL,
  default_shape_id char(64) DEFAULT NULL,
  surrounding_environment_id int(11) NOT NULL,
  uv tinyint(1) DEFAULT '0',
  non_slip tinyint(1) DEFAULT '0',
  min_ot smallint(3) NOT NULL,
  max_ot smallint(3) NOT NULL,  PRIMARY KEY (id),
  UNIQUE KEY target_category_positions_unique_idx (position_id,target_category_id,kit_type_id),
  KEY target_category_positions_target_category_id_idx (target_category_id),
  KEY target_category_positions_kit_type_id_idx (kit_type_id),
  CONSTRAINT target_category_positions_kit_type_id_fk FOREIGN KEY (kit_type_id) REFERENCES kit_types (id) ON DELETE CASCADE,
  CONSTRAINT target_category_positions_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE,
  CONSTRAINT target_category_positions_target_category_id_fk FOREIGN KEY (target_category_id) REFERENCES target_categories (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS target_category_shapes;


CREATE TABLE target_category_shapes (
  id int(11) NOT NULL AUTO_INCREMENT,
  target_category_position_id int(11) DEFAULT NULL,
  shape_id char(64) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_target_category_shapes_uniquely (target_category_position_id,shape_id),
  CONSTRAINT target_category_shapes_shape_id_fk FOREIGN KEY (shape_id) REFERENCES shapes (id) ON DELETE CASCADE,
  CONSTRAINT target_category_shapes_target_category_position_id_fk FOREIGN KEY (target_category_position_id) REFERENCES target_category_positions (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS target_characteristics;


CREATE TABLE target_characteristics (
  id int(11) NOT NULL AUTO_INCREMENT,
  value decimal(10,3) NOT NULL,
  target_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  characteristic_id int(11) NOT NULL,
  PRIMARY KEY (id),
  KEY target_characteristics_unique_idx (target_id,characteristic_id),
  CONSTRAINT target_characteristics_characteristic_id_fk FOREIGN KEY (characteristic_id) REFERENCES characteristics (id) ON DELETE CASCADE,
  CONSTRAINT target_characteristics_target_id_fk FOREIGN KEY (target_id) REFERENCES targets (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS target_icons;


CREATE TABLE target_icons (
  id int(11) NOT NULL AUTO_INCREMENT,
  target_type_id int(11) NOT NULL,
  target_category_id int(11) DEFAULT NULL,
  manufacturer_id int(11) NOT NULL,
  target_id int(11) DEFAULT NULL,
  target_kit_id int(11) DEFAULT NULL,
  icon_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY target_icons_unique_idx (target_type_id, target_category_id, manufacturer_id, target_id, target_kit_id,icon_id),
  CONSTRAINT target_icons_icon_id_fk FOREIGN KEY (icon_id) REFERENCES icons (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS target_kits;


CREATE TABLE target_kits (
  id int(11) NOT NULL AUTO_INCREMENT,
  target_id int(11) NOT NULL,
  kit_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  qualifying_data varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  colour_palette_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_target_kits_on_target_id_and_qualifying_data (target_id,qualifying_data),
  KEY target_kits_kit_id_idx (kit_id),
  CONSTRAINT target_kits_kit_id_idx FOREIGN KEY (kit_id) REFERENCES kits (id) ON DELETE CASCADE,
  CONSTRAINT target_kits_target_id_fk FOREIGN KEY (target_id) REFERENCES targets (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS target_type_positions;


CREATE TABLE target_type_positions (
  id int(11) NOT NULL AUTO_INCREMENT,
  target_type_id int(11) NOT NULL,
  position_id int(11) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY target_type_positions_unique_idx (target_type_id, position_id),
  CONSTRAINT target_type_positions_target_type_id_fk FOREIGN KEY (target_type_id) REFERENCES target_types (id),
  CONSTRAINT target_type_positions_position_id_fk FOREIGN KEY (position_id) REFERENCES positions (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS target_type_decals;


CREATE TABLE target_type_decals (
  id int(11) NOT NULL AUTO_INCREMENT,
  target_type_id int(11) DEFAULT NULL,
  decal_id int(11) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY target_type_decals_unique_idx (target_type_id, decal_id),
  CONSTRAINT target_type_decals_target_type_id_fk FOREIGN KEY (target_type_id) REFERENCES target_types (id) ON DELETE CASCADE,
  CONSTRAINT target_type_decals_decal_id_fk FOREIGN KEY (decal_id) REFERENCES decals (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS target_types;


CREATE TABLE target_types (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;






DROP TABLE IF EXISTS targets;


CREATE TABLE targets (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  target_type_id int(11) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  manufacturer_id int(11) NOT NULL,
  target_category_id int(11) NOT NULL,
  font_palette_id int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY index_targets_uniquely (name,manufacturer_id,target_category_id,target_type_id),
  KEY targets_manufacturer_id_fk (manufacturer_id),
  KEY targets_target_type_id_fk (target_type_id),
  KEY targets_target_category_id_fk (target_category_id),
  CONSTRAINT targets_target_category_id_fk FOREIGN KEY (target_category_id) REFERENCES target_categories (id) ON DELETE CASCADE,
  CONSTRAINT targets_manufacturer_id_fk FOREIGN KEY (manufacturer_id) REFERENCES manufacturers (id) ON DELETE CASCADE,
  CONSTRAINT targets_target_type_id_fk FOREIGN KEY (target_type_id) REFERENCES target_types (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS textures;


CREATE TABLE textures (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  ranking tinyint NOT NULL DEFAULT 0,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY textures_unique_idx (name),
  KEY `ranking` (`ranking`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS themes;

CREATE TABLE themes (
  id                   INT(11)       UNSIGNED NOT NULL AUTO_INCREMENT,

  spreadsheet_row_id   INT(11)       NOT NULL,
  product_line_id      INT(11)       NOT NULL,

  target_category_id   INT(11)       NOT NULL,
  target_kit_id        INT(11),
  target_id            INT(11),

  regulation_id        INT(11),

  display_name         VARCHAR(255)  NOT NULL,

  original_design_link TEXT,

  visible              TINYINT(1)    NOT NULL DEFAULT 1,
  description          TEXT          NOT NULL,
  design_time          INT(11)       UNSIGNED,

  author_id            INT(11)       UNSIGNED NOT NULL,
  category_id          INT(11)       UNSIGNED,

  popular              TINYINT(1)    NOT NULL DEFAULT 0,
  new                  TINYINT(1)    NOT NULL DEFAULT 0,

  price_multiplier     DECIMAL(3, 2) NOT NULL,
  PRIMARY KEY (id),

  KEY themes_target_kit (target_kit_id),
  KEY themes_target_category (target_category_id),

  UNIQUE KEY themes_product_line_spreadsheet_row_id_unique_idx (product_line_id, spreadsheet_row_id),

  CONSTRAINT themes_product_line_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE,
  CONSTRAINT themes_target_kit_fk FOREIGN KEY (target_kit_id) REFERENCES target_kits (id) ON DELETE CASCADE,
  CONSTRAINT themes_target_fk FOREIGN KEY (target_id) REFERENCES targets (id) ON DELETE CASCADE,
  CONSTRAINT themes_target_category_fk FOREIGN KEY (target_category_id) REFERENCES target_categories (id) ON DELETE CASCADE,
  CONSTRAINT themes_category_id_fk FOREIGN KEY (category_id) REFERENCES theme_categories (id) ON DELETE CASCADE,
  CONSTRAINT theme_author_id_fk FOREIGN KEY (author_id) REFERENCES theme_authors (id) ON DELETE CASCADE,
  CONSTRAINT theme_regulation_id_fk FOREIGN KEY (regulation_id) REFERENCES regulations (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS theme_authors;

CREATE TABLE theme_authors (
  id INT(11)    UNSIGNED NOT NULL AUTO_INCREMENT,
  email         VARCHAR(255) NOT NULL,
  name          VARCHAR(80) NOT NULL,
  phone_number  VARCHAR(50) NOT NULL,
  designer      TINYINT(1)  NOT NULL DEFAULT 0,
  speciality    VARCHAR(20),
  speciality_text_badge         TEXT,
  speciality_json_badge         TEXT,
  themes_count  INT(11)     NOT NULL DEFAULT 0,
  country_iso_code2 varchar(2) NOT NULL,
  PRIMARY KEY(id),
  UNIQUE KEY theme_authors_email_idx (email),
  CONSTRAINT theme_authors_country_iso_code2_fk FOREIGN KEY (country_iso_code2) REFERENCES countries (iso_code2) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS theme_categories;

CREATE TABLE theme_categories (
  id      INT(11)     UNSIGNED NOT NULL AUTO_INCREMENT,
  name    VARCHAR(80) NOT NULL,
  product_line_id INT(11) NOT NULL,
  spreadsheet_row_id INT(11) NOT NULL,
  spreadsheet_order  INT(11) UNSIGNED NOT NULL DEFAULT 100,
  PRIMARY KEY(id),
  UNIQUE KEY theme_categories_name_product_line_id_unique (product_line_id, name),
  CONSTRAINT theme_categories_product_line_id_fk FOREIGN KEY (product_line_id) REFERENCES product_lines (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS theme_tag_categories;

CREATE TABLE theme_tag_categories (
  id                   INT(11)     UNSIGNED NOT NULL AUTO_INCREMENT,
  name                 VARCHAR(80) NOT NULL,
  product_line_id      INT(11) NOT NULL,
  spreadsheet_order    INT(11) NOT NULL,
  PRIMARY KEY(id),
  UNIQUE KEY theme_tag_categories_name_product_line_id_idx (product_line_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS theme_tags;

CREATE TABLE theme_tags (
  id          INT(11)       UNSIGNED NOT NULL AUTO_INCREMENT,
  theme_id    INT(11)       UNSIGNED NOT NULL,
  category_id INT(11)       UNSIGNED NOT NULL,
  name        VARCHAR(80)            NOT NULL,
  spreadsheet_order          INT(11) NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT theme_tags_theme_id_fk FOREIGN KEY (theme_id) REFERENCES themes (id) ON DELETE CASCADE,
  CONSTRAINT theme_tags_category_id_fk FOREIGN KEY (category_id) REFERENCES theme_tag_categories (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS theme_linked_features;

CREATE TABLE theme_linked_features (
  id       INT(11)     NOT NULL AUTO_INCREMENT,
  theme_id INT(11)     UNSIGNED NOT NULL,
  feature_id    INT(11) NOT NULL,
  target_category_position_id INT(11) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT themes_linked_features_theme_id_fk FOREIGN KEY (theme_id) REFERENCES themes (id) ON DELETE CASCADE,
  CONSTRAINT themes_linked_features_feature_fk FOREIGN KEY (feature_id) REFERENCES features (id) ON DELETE CASCADE,
  CONSTRAINT themes_linked_features_tc_position_id_fk FOREIGN KEY (target_category_position_id) REFERENCES target_category_positions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS theme_previews;

CREATE TABLE theme_previews (
  id       INT(11)     UNSIGNED NOT NULL AUTO_INCREMENT,
  theme_id INT(11)     UNSIGNED NOT NULL,
  name varchar(255)    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY theme_previews_theme_id_name_idx (theme_id, name),
  CONSTRAINT theme_previews_theme_id_fk FOREIGN KEY (theme_id) REFERENCES themes (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


DROP TABLE IF EXISTS use_categories;


CREATE TABLE use_categories (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  data mediumtext default null,
  PRIMARY KEY (id),
  UNIQUE KEY use_categories_unique_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;





DROP TABLE IF EXISTS uses;


CREATE TABLE uses (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  parent_id int(11) DEFAULT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  lft int(11) DEFAULT NULL,
  rgt int(11) DEFAULT NULL,
  depth int(11) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY uses_unique_idx (parent_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP VIEW IF EXISTS target_icons_view;

create view target_icons_view as select
   (select name from target_types where id = ti.target_type_id) as lob,
   (select name from target_categories where id = ti.target_category_id) as category,
   (select name from manufacturers where id = ti.manufacturer_id) as manufacturer,
   (select name from targets where id = ti.target_id) as target,
   (select substring(qualifying_data,0,8) from target_kits tk where tk.id = ti.target_kit_id) as years,
   icon_id
from target_icons ti;


drop view if exists target_kits_view;

create view target_kits_view as
select (select name from target_types tt where tt.id = t.target_type_id) as lob,
       (select name from manufacturers m where m.id = t.manufacturer_id) as manufacturer,
       tk.id as target_kit_id, t.name, qualifying_data from targets t, target_kits tk where t.id = tk.target_id
       order by lob, manufacturer, t.name, qualifying_data;


DROP VIEW IF EXISTS fpr_view;

CREATE VIEW fpr_view as
select (select qualifying_data from target_kits tk where tk.id = fpr.target_kit_id) as years,
       (select name from targets t where id in (select target_id from target_kits where id = fpr.target_kit_id)) as target,
       (select name from target_categories tc where tc.id = fpr.target_category_id) as category,
       (select name from positions p where p.id = fpr.position_id) as position,
       (select name from features f where f.id = fpr.feature_id) as feature
       from feature_placement_removals fpr
       order by target, years, position, feature;





/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
