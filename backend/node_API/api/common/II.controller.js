const {
  create,
  show,
  search,
  show_by_id,
  show_by_user,
  show_tags,
  update,
  add_image,
  up_vote,
  down_vote,
  remove,
  add_tag,
  search_tags,
} = require("./I.service");
const logger = require("../../logger/logger");

module.exports = {
  create: (req, res) => {
    const body = req.body;
    create(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"POST node_api/create" - 200');
      return res.status(200).send(results);
    });
  },
  show: (req, res) => {
    const body = req.body;
    show(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"POST node_api/show" - 200');
      return res.status(200).send(results);
    });
  },
  search: (req, res) => {
    const body = req.body;
    search(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      // logger.info('"POST node_api/search" - 200');
      return res.status(200).send(results);
    });
  },
  show_by_id: (req, res) => {
    const body = req.body;
    show_by_id(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"POST node_api/show_by_id" - 200');
      return res.status(200).send(results);
    });
  },
  show_by_user: (req, res) => {
    const body = req.body;
    show_by_user(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"POST node_api/show_by_user" - 200');
      return res.status(200).send(results);
    });
  },
  show_tags: (req, res) => {
    const body = req.body;
    show_tags(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"POST node_api/show_tags" - 200');
      return res.status(200).send(results);
    });
  },
  update: (req, res) => {
    const body = req.body;
    update(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"PATCH node_api/update" - 200');
      return res.status(200).send(results);
    });
  },
  add_image: (req, res) => {
    const body = req.body;
    add_image(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"PATCH node_api/add_image" - 200');
      return res.status(200).send(results);
    });
  },
  up_vote: (req, res) => {
    const body = req.body;
    up_vote(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"PATCH node_api/up_vote" - 200');
      return res.status(200).send(results);
    });
  },
  down_vote: (req, res) => {
    const body = req.body;
    down_vote(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"PATCH node_api/down_vote" - 200');
      return res.status(200).send(results);
    });
  },
  remove: (req, res) => {
    const body = req.body;
    remove(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"PATCH node_api/remove" - 200');
      return res.status(200).send(results);
    });
  },
  add_tag: (req, res) => {
    const body = req.body;
    add_tag(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"PATCH node_api/add_tag" - 200');
      return res.status(200).send(results);
    });
  },
  search_tags: (req, res) => {
    const body = req.body;
    search_tags(body, (err, results) => {
      if (err) {
        logger.error(`"${err}" - 500`);
        return res.status(500).send("Database connection error");
      }
      logger.info('"POST node_api/search_tags" - 200');
      return res.status(200).send(results);
    });
  },
};
