SET
    FOREIGN_KEY_CHECKS = 0;

-- DROP IF EXISTS
DROP TABLE IF EXISTS `district`,
`factory`,
`fire`,
`fire_burns_stand`,
`landowner`,
`municipality`,
`operation`,
`parish`,
`person_of_contact`,
`phone`,
`product`,
`product_in_storehouse_is_for_sale`,
`product_stored_in_storehouse`,
`property`,
`property_belongs_to_owner`,
`sale`,
`sale_profit_distributed_to_owner`,
`spouse`,
`stand`,
`stand_borders_stand`,
`stand_is_subjected_to_operation`,
`storehouse`,
`wood_operation`;

-- CREATE TABLES
CREATE TABLE landowner (
    VAT NUMERIC(9) NOT NULL,
    name VARCHAR(60) NOT NULL,
    address VARCHAR(100) NOT NULL,
    birthdate DATE,
    CONSTRAINT pk_landowner PRIMARY KEY(VAT)
);

CREATE TABLE spouse (
    landowner_VAT NUMERIC(9) NOT NULL,
    name VARCHAR(60) NOT NULL,
    birthdate DATE,
    phone NUMERIC(9),
    country_code VARCHAR(5),
    FOREIGN KEY (landowner_VAT) REFERENCES landowner (VAT) ON DELETE CASCADE,
    CONSTRAINT pk_spouse PRIMARY KEY (landowner_VAT, name)
);

CREATE TABLE phone (
    landowner_VAT NUMERIC(9),
    phone_number NUMERIC(9),
    country_code VARCHAR(5),
    FOREIGN KEY (landowner_VAT) REFERENCES landowner (VAT) ON DELETE CASCADE,
    CONSTRAINT pk_phone PRIMARY KEY (phone_number)
);

CREATE TABLE property (
    pid NUMERIC (9),
    area NUMERIC (25, 2) NOT NULL,
    parish_id NUMERIC(9),
    FOREIGN KEY (parish_id) REFERENCES parish (pid),
    CONSTRAINT pk_property PRIMARY KEY (pid)
);

CREATE TABLE property_belongs_to_owner (
    property_id NUMERIC(9),
    landowner_VAT NUMERIC(9),
    FOREIGN KEY (property_id) REFERENCES property (pid) ON DELETE CASCADE,
    FOREIGN KEY (landowner_VAT) REFERENCES landowner (VAT) ON DELETE CASCADE,
    CONSTRAINT pk_property_belongs_to_owner PRIMARY KEY (property_id, landowner_VAT)
);

CREATE TABLE parish (
    pid NUMERIC (9),
    municipality_id NUMERIC (9),
    name VARCHAR (60) NOT NULL,
    FOREIGN KEY (municipality_id) REFERENCES municipality (mid) ON DELETE CASCADE,
    CONSTRAINT pk_parish PRIMARY KEY (pid)
);

CREATE TABLE municipality (
    mid NUMERIC (9),
    district_id NUMERIC (9),
    name VARCHAR (60) NOT NULL,
    FOREIGN KEY (district_id) REFERENCES district (did) ON DELETE CASCADE,
    CONSTRAINT pk_municipality PRIMARY KEY (mid)
);

CREATE TABLE district (
    did NUMERIC (9),
    name VARCHAR (60) NOT NULL,
    CONSTRAINT pk_district PRIMARY KEY (did)
);

CREATE TABLE stand (
    sid NUMERIC (9),
    property_id NUMERIC (9),
    area NUMERIC (25, 2) NOT NULL,
    year YEAR (4) NOT NULL,
    species VARCHAR(30),
    FOREIGN KEY (property_id) REFERENCES property (pid) ON DELETE CASCADE,
    CONSTRAINT pk_stand PRIMARY KEY (sid)
);

CREATE TABLE stand_borders_stand (
    stand1_id NUMERIC(9),
    stand2_id NUMERIC(9),
    FOREIGN KEY (stand1_id) REFERENCES stand (sid) ON DELETE CASCADE,
    FOREIGN KEY (stand2_id) REFERENCES stand (sid) ON DELETE CASCADE,
    CONSTRAINT pk_stand_borders_stand PRIMARY KEY(stand1_id, stand2_id)
);

CREATE TABLE operation (
    oid NUMERIC (9),
    operation_type VARCHAR(30),
    cost_hectare NUMERIC (12, 2) NOT NULL,
    CONSTRAINT pk_operation PRIMARY KEY (oid)
);

CREATE TABLE wood_operation (
    woid NUMERIC (9),
    wood_produced NUMERIC (25),
    FOREIGN KEY (woid) REFERENCES operation (oid) ON DELETE CASCADE,
    CONSTRAINT pk_wood_operation PRIMARY KEY (woid)
);

CREATE TABLE stand_is_subjected_to_operation (
    stand_id NUMERIC(9),
    operation_id NUMERIC(9),
    total_cost NUMERIC(12, 2),
    date DATE,
    FOREIGN KEY (stand_id) REFERENCES stand (sid),
    FOREIGN KEY (operation_id) REFERENCES operation (oid),
    CONSTRAINT pk_stand_is_subject_to_operation PRIMARY KEY (stand_id, operation_id)
);

CREATE TABLE fire (
    fid NUMERIC (9),
    fire_type VARCHAR (30) NOT NULL,
    start_location VARCHAR (30),
    start_date DATE,
    CONSTRAINT pk_fire PRIMARY KEY (fid)
);

CREATE TABLE fire_burns_stand (
    fire_id NUMERIC(9),
    stand_id NUMERIC(9),
    burnt_percent NUMERIC(3),
    FOREIGN KEY (fire_id) REFERENCES fire (fid) ON DELETE CASCADE,
    FOREIGN KEY (stand_id) REFERENCES stand (sid) ON DELETE CASCADE,
    CONSTRAINT pk_fire_burns_stand PRIMARY KEY (fire_id, stand_id)
);

CREATE TABLE product (
    pid NUMERIC (9),
    product_type VARCHAR (30),
    price_m3 NUMERIC (12, 2),
    CONSTRAINT pk_product PRIMARY KEY (pid)
);

CREATE TABLE storehouse (
    sid NUMERIC (9),
    CONSTRAINT pk_storehouse PRIMARY KEY (sid)
);

CREATE TABLE product_stored_in_storehouse (
    product_id NUMERIC(9),
    storehouse_id NUMERIC(9),
    amount_in_stock NUMERIC(10),
    FOREIGN KEY (product_id) REFERENCES product (pid) ON DELETE CASCADE,
    FOREIGN KEY (storehouse_id) REFERENCES storehouse(sid) ON DELETE CASCADE,
    CONSTRAINT pk_product_stored_in_storehouse PRIMARY KEY (product_id, storehouse_id)
);

CREATE TABLE factory (
    MIPC NUMERIC(9),
    company_name VARCHAR(30),
    factory_type VARCHAR(30),
    owner_name VARCHAR(30),
    address VARCHAR(30),
    CONSTRAINT pk_factory PRIMARY KEY (MIPC)
);

CREATE TABLE person_of_contact (
    factory_MIPC NUMERIC(9),
    name VARCHAR(30),
    phone_number NUMERIC(9),
    FOREIGN KEY (factory_MIPC) REFERENCES factory (MIPC) ON DELETE CASCADE,
    CONSTRAINT pk_person_of_contact PRIMARY KEY (factory_MIPC, name)
);

CREATE TABLE sale (
    sid NUMERIC(9),
    factory_MIPC NUMERIC(9),
    type_of_wood VARCHAR(30),
    amount_of_wood_sold NUMERIC(25),
    price_m3 NUMERIC (12, 2),
    total_price NUMERIC (12, 2),
    date_wood_left_storehouse DATE,
    FOREIGN KEY (factory_MIPC) REFERENCES factory (MIPC),
    CONSTRAINT pk_sale PRIMARY KEY (sid)
);

CREATE TABLE product_in_storehouse_is_for_sale (
    product_id NUMERIC(9),
    storehouse_id NUMERIC(9),
    sale_id NUMERIC(9),
    FOREIGN KEY (product_id) REFERENCES product (pid) ON DELETE CASCADE,
    FOREIGN KEY (storehouse_id) REFERENCES storehouse (sid) ON DELETE CASCADE,
    FOREIGN KEY (sale_id) REFERENCES sale (sid) ON DELETE CASCADE,
    CONSTRAINT pk_product_in_storehouse_is_for_sale PRIMARY KEY (product_id, storehouse_id, sale_id)
);

CREATE TABLE sale_profit_distributed_to_owner (
    sale_id NUMERIC(9),
    landowner_VAT NUMERIC(9),
    property_id NUMERIC(9),
    profit_percent NUMERIC(3),
    profit_nominal_value NUMERIC(25),
    FOREIGN KEY (sale_id) REFERENCES sale (sid),
    FOREIGN KEY (landowner_VAT) REFERENCES landowner (VAT) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES property (pid),
    CONSTRAINT pk_sale_profit_distributed_to_owner PRIMARY KEY (sale_id, landowner_VAT, property_id)
);

SET
    FOREIGN_KEY_CHECKS = 1;

-- POPULATE TABLES
INSERT INTO
    landowner (VAT, name, address, birthdate)
VALUES
    (
        111111111,
        "Amália Rodrigues",
        "Campo de Santa Clara, Lisboa",
        "1920-07-23"
    );

INSERT INTO
    spouse (
        landowner_VAT,
        name,
        birthdate,
        phone,
        country_code
    )
VALUES
    (
        111111111,
        "César Seabra",
        "1917-03-21",
        912324456,
        "+351"
    );

INSERT INTO
    phone (landowner_VAT, phone_number, country_code)
VALUES
    (111111111, 916582368, "+351");

INSERT INTO
    property (pid, area)
VALUES
    (314, 2134.50);

INSERT INTO
    property_belongs_to_owner (property_id, landowner_VAT)
VALUES
    (314, 111111111);

INSERT INTO
    district (did, name)
VALUES
    (265, "Setúbal");

INSERT INTO
    municipality (mid, district_id, name)
VALUES
    (7570, 265, "Grândola");

INSERT INTO
    parish (pid, municipality_id, name)
VALUES
    (779, 7570, "Carvalhal");

INSERT INTO
    stand (sid, property_id, area, year, species)
VALUES
    (815606, 314, 711.5, 1974, "Eucalyptus"),
    (525302, 314, 711.5, 1974, "Oak"),
    (140080, 314, 711.5, 1974, "Cypress");

INSERT INTO
    stand_borders_stand (stand1_id, stand2_id)
VALUES
    (815606, 525302),
    (525302, 140080),
    (815606, 140080);

INSERT INTO
    operation (oid, operation_type, cost_hectare)
VALUES
    (3780, "Plantation", 2500),
    (3781, "Forest Cleaning", 3000),
    (3782, "Thinning", 1400),
    (3783, "Inventory Measurement", 1200),
    (3784, "Final Harvest", 5000),
    (3785, "Coppice Cut", 2000);

INSERT INTO
    wood_operation (woid, wood_produced)
VALUES
    (3782, 900),
    (3785, 400),
    (3784, 1400);

INSERT INTO
    stand_is_subjected_to_operation (stand_id, operation_id, total_cost, date)
VALUES
    (525302, 3780, 177.68, "1974-05-01");

INSERT INTO
    fire (fid, fire_type, start_location, start_date)
VALUES
    (21653, "Ground", "Redondo", "1990-06-26"),
    (21654, "Canopy", "Penela", "1993-06-21"),
    (21655, "Canopy", "Grândola", "1999-10-06"),
    (21656, "Ground", "Almodôvar", "2001-08-12");

INSERT INTO
    fire_burns_stand (fire_id, stand_id, burnt_percent)
VALUES
    (21655, 815606, 100),
    (21655, 525302, 25);

INSERT INTO
    product (pid, product_type, price_m3)
VALUES
    (500899, "Eucalyptus", 12200),
    (500900, "Oak", 23123);

INSERT INTO
    storehouse (sid)
VALUES
    (9993837),
    (9993838),
    (9993839);

INSERT INTO
    product_stored_in_storehouse (product_id, storehouse_id, amount_in_stock)
VALUES
    (500899, 9993838, 50000),
    (500899, 9993839, 233321),
    (500900, 9993838, 89732);

INSERT INTO
    factory (MIPC, company_name, factory_type, owner_name, address)
VALUES
    (
        328619620,
        "Madeiras Lda.",
        "Saw Mill",
        "António Esteves", 
        "Estrada Nacional 238"
    ),
    (
        724232564,
        "Dunder Mifflin",
        "Pulp Company",
        "Miguel Scott",
        "Avenida Slough 200"
    ),
    (
        133953549,
        "Corticeira Amiga",
        "Cork Mill",
        "Susana Amorim",
        "Rua Principal 123"
    );

INSERT INTO
    person_of_contact (factory_MIPC, name, phone_number)
VALUES
    (328619620, "Fernanda Videira", 923293344),
    (724232564, "Duarte Schrute", 913320392),
    (133953549, "Roberta Amorim", 913925312);

INSERT INTO
    sale (
        sid,
        factory_MIPC,
        type_of_wood,
        amount_of_wood_sold,
        price_m3,
        total_price,
        date_wood_left_storehouse
    )
VALUES
    (
        2546601,
        724232564,
        "Eucalyptus",
        2300,
        12200,
        28060000,
        "2013-05-16"
    );

INSERT INTO
    product_in_storehouse_is_for_sale (product_id, storehouse_id, sale_id)
VALUES
    (500899, 9993838, 2546601);

INSERT INTO
    sale_profit_distributed_to_owner (
        sale_id,
        landowner_VAT,
        property_id,
        profit_percent,
        profit_nominal_value
    )
VALUES
    (2546601, 111111111, 314, 2, 12500);


